defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  import Jumubase.Utils, only: [get_ids: 1]
  alias Jumubase.Repo
  alias Jumubase.Utils
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host, Stage}

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

  def list_predecessor_hosts(%Contest{round: 2, season: season}) do
    query =
      from h in Host,
        join: c in assoc(h, :contests),
        where: c.season == ^season and c.round == 1,
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

  ## Contests

  @doc """
  Returns all contests.
  """
  def list_contests(query \\ Contest) do
    query =
      from c in query,
        join: h in assoc(c, :host),
        order_by: [{:desc, c.season}, {:desc, c.round}, h.name],
        preload: [host: h]

    Repo.all(query)
  end

  @doc """
  Returns all contests in a round whose deadline has't passed.
  """
  def list_open_contests(round) do
    query =
      from c in Contest,
        where: c.round == ^round,
        # uses UTC
        where: c.deadline >= ^Timex.today(),
        join: h in assoc(c, :host),
        order_by: h.name,
        preload: [host: h]

    Repo.all(query)
  end

  @doc """
  Returns all contests with public timetables.
  """
  def list_public_contests(opts \\ []) do
    query =
      from c in Contest,
        where: c.timetables_public,
        join: h in assoc(c, :host),
        join: cc in assoc(c, :contest_categories),
        join: p in assoc(cc, :performances),
        order_by: [{:desc, c.season}, {:desc, c.round}, h.name, cc.inserted_at],
        preload: [host: {h, [stages: ^stages_query()]}, contest_categories: {cc, :category}]

    query =
      if opts[:current_only] do
        query |> where(season: ^get_latest_season())
      else
        query
      end

    Repo.all(query)
    |> exclude_unused_stages
    |> exclude_stageless_contests
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
  Returns the number of contests as returned by the query.
  """
  def count_contests(query) do
    Repo.aggregate(query, :count, :id)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
  end

  def get_public_contest(id) do
    public_contests_query() |> Repo.get(id)
  end

  def get_public_contest!(id) do
    public_contests_query() |> Repo.get!(id)
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
  Returns the next-round contest that advancing performances go to,
  or nil if no such contest exists.
  """
  def get_successor(%Contest{season: season, round: 1}) do
    Contest
    |> where(season: ^season, round: 2)
    |> preload(:host)
    |> Repo.one()
  end

  def get_successor(%Contest{round: _}), do: nil

  @doc """
  Returns the official (non-Kimu) contest with the latest end date.
  """
  def get_latest_official_contest do
    Contest
    |> where([c], c.round > 0)
    |> order_by(desc: :end_date)
    |> limit(1)
    |> preload(:host)
    |> Repo.one()
  end

  def get_latest_season do
    Contest
    |> order_by(desc: :season)
    |> limit(1)
    |> select([c], c.season)
    |> Repo.one()
  end

  def update_contest(%Contest{} = contest, attrs) do
    contest
    |> Contest.changeset(attrs)
    |> Repo.update()
  end

  def change_contest(%Contest{} = contest) do
    Contest.changeset(contest, %{})
  end

  @doc """
  Returns the date range on which the contest takes place.
  """
  def date_range(%Contest{start_date: start_date, end_date: end_date}) do
    Date.range(start_date, end_date)
  end

  @doc """
  Returns the most common deadline within the given contests.
  """
  def general_deadline(contests) do
    contests
    |> Enum.map(& &1.deadline)
    |> Utils.mode()
    |> List.first()
  end

  ## Categories

  def list_categories do
    Repo.all(Category)
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
    |> preload([_], :category)
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

  # Build a query for fetching public contests.
  defp public_contests_query do
    Contest
    |> where(timetables_public: true)
    |> preload(:host)
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
end
