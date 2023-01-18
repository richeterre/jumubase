defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  import Jumubase.Utils, only: [get_ids: 1]
  alias Ecto.Multi
  alias Jumubase.Repo
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, ContestSeed, Host, Stage}
  alias Jumubase.Foundation.ContestFilter

  ## Hosts

  def list_hosts do
    query = from h in Host, order_by: [:current_grouping, :name]
    Repo.all(query)
  end

  def list_hosts(ids) do
    Repo.all(from h in Host, where: h.id in ^ids)
  end

  def list_hosts_by_grouping(grouping) do
    query =
      from h in Host,
        where: h.current_grouping == ^grouping,
        order_by: :name

    Repo.all(query)
  end

  def list_hosts_for_user(%User{id: u_id}) do
    query =
      from h in Host,
        join: u in assoc(h, :users),
        where: u.id == ^u_id

    Repo.all(query)
  end

  @doc """
  Returns the predecessor hosts of the contest's performances.
  """
  def list_performance_predecessor_hosts(%Contest{id: c_id, round: 2}) do
    query =
      from h in Host,
        join: p in assoc(h, :successor_performances),
        join: cc in assoc(p, :contest_category),
        where: cc.contest_id == ^c_id,
        order_by: h.name,
        distinct: true

    Repo.all(query)
  end

  def get_host!(id) do
    Repo.get!(Host, id)
  end

  def create_host(attrs) do
    Host.changeset(%Host{}, attrs) |> Repo.insert()
  end

  def update_host(%Host{} = host, attrs) do
    host
    |> Host.changeset(attrs)
    |> Repo.update()
  end

  def change_host(%Host{} = host) do
    Host.changeset(host, %{})
  end

  def country_codes(%Host{country_code: "IL/PS"}), do: ["IL", "PS"]
  def country_codes(%Host{} = h), do: [h.country_code]

  ## Contests

  @doc """
  Returns all contests.
  """
  def list_contests(query \\ Contest) do
    query
    |> ordered_with_hosts_preloaded()
    |> Repo.all()
  end

  def list_contests(query, %ContestFilter{} = filter) do
    query
    |> ordered_with_hosts_preloaded()
    |> apply_filter(filter)
    |> Repo.all()
  end

  @doc """
  Returns all contests in a round that allow registration and whose deadline has't passed.
  """
  def list_open_contests(round) do
    query =
      from c in Contest,
        where: c.round == ^round,
        where: c.allows_registration,
        # We don't currently consider host time zone in deadline check:
        where: c.deadline >= ^Timex.today(),
        join: h in assoc(c, :host),
        order_by: [h.name, c.start_date],
        preload: [host: h]

    Repo.all(query)
  end

  @doc """
  Returns all contests with public timetables.
  """
  def list_public_contests() do
    query =
      public_contests_query()
      |> preloaded_with_stages
      |> order_by([contests: c], desc: c.start_date, desc: c.end_date, desc: c.round)
      |> order_by([hosts: h, contest_categories: cc], [h.name, cc.inserted_at])

    Repo.all(query)
    |> exclude_unused_stages
    |> exclude_stageless_contests
  end

  def list_featured_contests(limit) do
    today = Timex.today()
    earliest_end = Timex.shift(today, days: -1)
    latest_start = Timex.shift(today, days: 14)

    public_contests_query()
    |> where([contests: c], c.start_date <= ^latest_start and c.end_date >= ^earliest_end)
    |> preloaded_with_stages
    |> order_by([contests: c], [c.start_date, c.end_date])
    |> Repo.all()
    |> exclude_unused_stages
    |> exclude_stageless_contests
    |> Enum.take(limit)
  end

  @doc """
  Returns the latest contests relevant to the given user,
  i.e. own contests and, for non-local users, LW contests.
  """
  def list_latest_relevant_contests(query, user) do
    case get_latest_season() do
      nil ->
        []

      latest_season ->
        query
        |> relevant_for_user(user)
        |> where(season: ^latest_season)
        |> list_contests
    end
  end

  @doc """
  Returns contests that can act as a "category template" when
  creating new contests with a similar selection of categories.
  """
  def list_template_contests(season, round) do
    Contest
    |> where(round: ^round, season: ^season - 3)
    |> list_contests()
  end

  @doc """
  Returns the number of contests as returned by the query.
  """
  def count_contests(query) do
    Repo.aggregate(query, :count, :id)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
  end

  def get_public_contest(id) do
    public_contests_query() |> preload(:host) |> Repo.get(id)
  end

  def get_public_contest!(id) do
    public_contests_query() |> preload(:host) |> Repo.get!(id)
  end

  @doc """
  Returns the Kimu contest whose season and host matches the given RW contest,
  or nil if no such Kimu contest exists or the given contest is not a RW.
  """
  def get_matching_kimu_contest(%Contest{round: 1} = c) do
    Contest
    |> where(host_id: ^c.host_id, season: ^c.season, round: 0)
    |> Repo.one()
  end

  def get_matching_kimu_contest(%Contest{}), do: nil

  @doc """
  Returns all next-round contests that performances of the given contest might advance to.
  """
  def get_successors(%Contest{season: season, round: 1, grouping: grouping}) do
    Contest
    |> where(season: ^season, round: 2, grouping: ^grouping)
    |> preload(:host)
    |> Repo.all()
  end

  def get_successors(%Contest{round: _}), do: []

  @doc """
  Returns the latest contest that is open for regisration.
  """
  def get_latest_open_contest(round) do
    Contest
    |> where(round: ^round)
    |> where(allows_registration: true)
    |> where([c], c.deadline >= ^Timex.today())
    |> order_by(desc: :end_date)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Returns whether any currently ongoing contests exist in the round.
  """
  def has_ongoing_contests?(round) do
    today = Timex.today()

    Contest
    |> where(round: ^round)
    |> where([c], c.start_date <= ^today and c.end_date >= ^today)
    |> Repo.exists?()
  end

  @doc """
  Returns all seasons for which at least one contest exists.
  """
  def list_seasons do
    Contest
    |> select([c], c.season)
    |> order_by(desc: :season)
    |> distinct(true)
    |> Repo.all()
  end

  def create_contests(%ContestSeed{season: season, round: round, contest_categories: ccs}, hosts) do
    # Generate default dates
    year = JumuParams.year(season)
    {:ok, start_date} = Date.new(year, 1, 1)
    {:ok, deadline} = Date.new(year - 1, 12, 15)

    multi =
      Enum.reduce(hosts, Multi.new(), fn host, acc ->
        contest_cs =
          %Contest{}
          |> Contest.changeset(%{
            season: season,
            round: round,
            grouping: host.current_grouping,
            host_id: host.id,
            start_date: start_date,
            end_date: start_date,
            deadline: deadline,
            dates_verified: false,
            allows_registration: false,
            timetables_public: false
          })
          |> Ecto.Changeset.put_assoc(:contest_categories, ccs)

        Multi.insert(acc, host.id, contest_cs)
      end)

    Repo.transaction(multi)
  end

  def update_contest(%Contest{} = contest, attrs) do
    contest
    |> Contest.changeset(attrs)
    |> Repo.update()
  end

  def change_contest(%Contest{} = contest) do
    Contest.changeset(contest, %{})
  end

  def delete_contest!(%Contest{} = contest) do
    Repo.delete!(contest)
  end

  @doc """
  Adds and verifies contest dates (e.g. deadline) that initially got placeholder values.
  While updating the contest, we also set the flag to allow registration.
  """
  def verify_dates_and_open_contest(%Contest{} = contest, attrs) do
    contest
    |> Contest.dates_changeset(attrs)
    |> Ecto.Changeset.change(allows_registration: true)
    |> Repo.update()
  end

  def publish_contest_timetables(%Contest{} = contest) do
    contest
    |> Ecto.Changeset.change(timetables_public: true)
    |> Repo.update()
  end

  def unpublish_contest_timetables(%Contest{} = contest) do
    contest
    |> Ecto.Changeset.change(timetables_public: false)
    |> Repo.update()
  end

  @doc """
  Returns the date range on which the contest takes place.
  """
  def date_range(%Contest{start_date: start_date, end_date: end_date}) do
    Date.range(start_date, end_date)
  end

  ## Categories

  def list_categories do
    Category
    |> order_by(desc: :type)
    |> order_by(:genre)
    |> order_by(:name)
    |> Repo.all()
  end

  def get_category!(id) do
    Repo.get!(Category, id)
  end

  def create_category(attrs) do
    Category.changeset(%Category{}, attrs) |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  def list_contest_categories(%Contest{} = contest) do
    ContestCategory
    |> where(contest_id: ^contest.id)
    |> order_by(:inserted_at)
    |> preload(:category)
    |> Repo.all()
  end

  @doc """
  Gets a single contest category from the given contest.

  Raises `Ecto.NoResultsError` if the contest category isn't found in that contest.
  """
  def get_contest_category!(%Contest{id: contest_id}, id) do
    ContestCategory
    |> where([cc], cc.contest_id == ^contest_id)
    |> Repo.get!(id)
  end

  ## Stages

  def get_stage!(%Contest{id: contest_id}, id) do
    query =
      from s in Stage,
        join: h in assoc(s, :host),
        join: c in assoc(h, :contests),
        where: c.id == ^contest_id

    Repo.get!(query, id)
  end

  def create_stage(%Host{} = host, attrs) do
    Ecto.build_assoc(host, :stages)
    |> Stage.changeset(attrs)
    |> Repo.insert()
  end

  ## Preloading

  def load_host_users(%Contest{} = contest) do
    Repo.preload(contest, host: :users)
  end

  def load_contest_categories(%Contest{} = contest) do
    query = from cc in ContestCategory, order_by: :inserted_at
    Repo.preload(contest, contest_categories: {query, :category})
  end

  @doc """
  Preloads all stages available to the contest.
  """
  def load_available_stages(%Contest{} = contest) do
    Repo.preload(contest, host: :stages)
  end

  @doc """
  Preloads only the contest's stages that have performances in that contest.
  """
  def load_used_stages(%Contest{} = contest) do
    contest
    |> Repo.preload([[host: [stages: stages_query()]], :contest_categories])
    |> exclude_unused_stages
  end

  @doc """
  Defines a Dataloader source.
  """
  def data do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _), do: queryable

  # Private helpers

  # Returns the latest season for which a contest exists.
  defp get_latest_season do
    Contest
    |> order_by(desc: :season)
    |> limit(1)
    |> select([c], c.season)
    |> Repo.one()
  end

  defp ordered_with_hosts_preloaded(query) do
    from c in query,
      join: h in assoc(c, :host),
      as: :hosts,
      order_by: [{:desc, c.season}, {:desc, c.round}, c.grouping, h.name, c.start_date],
      preload: [host: h]
  end

  defp apply_filter(query, %ContestFilter{} = filter) do
    filter_map = ContestFilter.to_filter_map(filter)

    Enum.reduce(filter_map, query, fn
      {:season, season}, query ->
        in_season(query, season)

      {:round, round}, query ->
        in_round(query, round)

      {:grouping, grouping}, query ->
        with_grouping(query, grouping)

      {:search_text, search_text}, query ->
        matching_search_text(query, search_text)

      _, query ->
        query
    end)
  end

  # Build a query for fetching public contests.
  defp public_contests_query do
    from c in Contest,
      as: :contests,
      where: c.timetables_public
  end

  # Build a query for fetching stages in display order.
  # This preloads performances to allow removing unused stages after executing the query.
  defp stages_query do
    from s in Stage, order_by: s.inserted_at, preload: :performances
  end

  # Filter nested contest stages by whether they have performances in that contest.
  defp exclude_unused_stages(%Contest{host: h} = c) do
    host = Map.put(h, :stages, used_stages(c))
    Map.put(c, :host, host)
  end

  defp exclude_unused_stages(contests) do
    Enum.map(contests, &exclude_unused_stages/1)
  end

  defp used_stages(%Contest{host: %{stages: stages}} = c) do
    cc_ids = c.contest_categories |> get_ids

    Enum.filter(stages, fn %{performances: p_list} ->
      Enum.any?(p_list, &(&1.contest_category_id in cc_ids))
    end)
  end

  # Exclude contests without any stages (e.g. because all were removed as unused)
  defp exclude_stageless_contests(contests) do
    Enum.filter(contests, &(not Enum.empty?(&1.host.stages)))
  end

  defp relevant_for_user(contest_query, %User{id: user_id, role: "local-organizer"}) do
    from [contests: c, users: u] in with_users(contest_query),
      where: u.id == ^user_id
  end

  defp relevant_for_user(contest_query, %User{id: user_id}) do
    from [contests: c, users: u] in with_users(contest_query),
      where: c.round == 2 or u.id == ^user_id
  end

  defp with_users(contest_query) do
    from c in contest_query,
      as: :contests,
      join: h in assoc(c, :host),
      left_join: u in assoc(h, :users),
      as: :users
  end

  defp in_season(contest_query, season) do
    from c in contest_query, where: c.season == ^season
  end

  defp in_round(contest_query, round) do
    from c in contest_query, where: c.round == ^round
  end

  defp with_grouping(contest_query, grouping) do
    from c in contest_query, where: c.grouping == ^grouping
  end

  defp matching_search_text(contest_query, text) do
    from [c, hosts: h] in contest_query, where: ilike(h.name, ^"%#{text}%")
  end

  defp preloaded_with_stages(contest_query) do
    from [contests: c] in contest_query,
      join: h in assoc(c, :host),
      as: :hosts,
      join: cc in assoc(c, :contest_categories),
      as: :contest_categories,
      join: p in assoc(cc, :performances),
      preload: [host: {h, [stages: ^stages_query()]}, contest_categories: {cc, :category}]
  end
end
