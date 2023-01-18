defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  import Ecto.Query
  import Ecto.Changeset
  alias Ecto.{Changeset, Multi}
  alias Jumubase.Repo
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, ContestCategory}
  alias Jumubase.Showtime.AgeGroupCalculator
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}
  alias Jumubase.Showtime.PerformanceFilter

  @doc """
  Checks whether the two strings are similar in that they begin or end the same way,
  disregarding capitalization and diacritical marks (accents).
  """
  defmacro similar(str1, str2) do
    quote do
      contains?(unquote(str1), unquote(str2)) or contains?(unquote(str2), unquote(str1))
    end
  end

  @doc """
  Returns an SQL fragment to check whether the second string is a substring of the first,
  disregarding capitalization and diacritical marks (accents).
  """
  defmacro contains?(str1, str2) do
    quote do
      fragment("unaccent(?) ILIKE '%' || unaccent(?) || '%'", unquote(str2), unquote(str1))
    end
  end

  @doc """
  Returns all performances from the contest.
  """
  def list_performances(%Contest{id: id}) do
    performances_query(id) |> preload(:stage) |> Repo.all()
  end

  @doc """
  Returns all performances from the contest matching the given constraints,
  such as a filter or list of ids.
  """
  def list_performances(%Contest{id: id}, %PerformanceFilter{} = filter) do
    performances_query(id)
    |> preload(:stage)
    |> apply_filter(filter)
    |> Repo.all()
  end

  def list_performances(%Contest{id: contest_id}, ids) when is_list(ids) do
    performances_query(contest_id)
    |> preload(:stage)
    |> where([p], p.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Returns the amount of performances without a stage time in the contest.
  """
  def unscheduled_performance_count(%Contest{id: c_id}) do
    performances_query(c_id)
    |> where([p], is_nil(p.stage_time))
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns all performances without a stage time from the contest.
  """
  def unscheduled_performances(%Contest{id: c_id}) do
    performances_query(c_id)
    |> where([p], is_nil(p.stage_time))
    |> Repo.all()
  end

  @doc """
  Returns the contest's scheduled performances that match the given filter.
  """
  def scheduled_performances(%Contest{id: c_id}, %PerformanceFilter{} = filter) do
    performances_query(c_id)
    |> where([p], not is_nil(p.stage_time))
    |> apply_filter(filter)
    |> Repo.all()
  end

  @doc """
  Returns all performances from the contest that advance to the next round.
  """
  def advancing_performances(%Contest{id: id}) do
    performances_query(id)
    |> Repo.all()
    |> Enum.filter(&Jumubase.Showtime.Results.advances?/1)
  end

  @doc """
  Gets a single performance from the given contest.

  Raises `Ecto.NoResultsError` if the performance isn't found in that contest.
  """
  def get_performance!(%Contest{id: contest_id}, id) do
    Performance
    |> preloaded_from_contest(contest_id)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single performance from the contest with the given edit code.

  Raises `Ecto.NoResultsError` if no matching performance is found in that contest.
  """
  def get_performance!(%Contest{id: contest_id}, id, edit_code) do
    Performance
    |> preloaded_from_contest(contest_id)
    |> Repo.get_by!(%{id: id, edit_code: edit_code})
  end

  @doc """
  Gets a single public, scheduled performance.

  Returns nil if the performance is not found, unscheduled or not part of a public contest.
  """
  def get_public_performance(id) do
    query =
      from p in Performance,
        join: cc in assoc(p, :contest_category),
        join: c in assoc(cc, :contest),
        where: c.timetables_public,
        where: not is_nil(p.stage_time),
        preload: [
          [contest_category: {cc, :category}],
          [appearances: :participant],
          [pieces: ^pieces_query()]
        ]

    Repo.get(query, id)
  end

  @doc """
  Looks up a performance with the given edit code.

  Returns an error tuple if no performance could be found.
  """
  def lookup_performance(edit_code) do
    case Repo.get_by(Performance, edit_code: edit_code) do
      nil ->
        {:error, :not_found}

      performance ->
        {:ok, Repo.preload(performance, contest_category: :contest)}
    end
  end

  @doc """
  Looks up a performance from the contest with the given edit code.

  Raises `Ecto.NoResultsError` if no performance isn't found for that contest and edit code.
  """
  def lookup_performance!(%Contest{id: contest_id}, edit_code) when is_binary(edit_code) do
    Performance
    |> preloaded_from_contest(contest_id)
    |> Repo.get_by!(edit_code: edit_code)
  end

  @doc """
  Returns a performance struct as a starting point for registration.
  Kimu contests typically have only one category, so we can pre-populate it.
  """
  def build_performance(%Contest{round: 0} = contest) do
    contest = Foundation.load_contest_categories(contest)

    case contest do
      %Contest{contest_categories: [%ContestCategory{id: cc_id}]} ->
        %Performance{
          contest_category_id: cc_id,
          appearances: [%Appearance{}],
          pieces: [%Piece{}]
        }

      _ ->
        %Performance{}
    end
  end

  def build_performance(%Contest{round: _}), do: %Performance{}

  def create_performance(%Contest{} = contest, attrs \\ %{}) do
    Performance.changeset(%Performance{}, attrs, contest.round)
    |> handle_category_specific_fields(contest, attrs)
    |> stitch_participants()
    |> put_age_groups(contest)
    |> attempt_insert(contest.round)
  end

  def update_performance(%Contest{} = contest, %Performance{} = performance, attrs \\ %{}) do
    if Performance.has_results?(performance) do
      {:error, :has_results}
    else
      performance
      |> Performance.changeset(attrs, contest.round)
      |> handle_category_specific_fields(contest, attrs)
      |> stitch_participants()
      |> put_age_groups(contest)
      |> Repo.update()
    end
  end

  def change_performance(%Performance{} = performance) do
    performance
    |> Repo.preload([:appearances, :pieces])
    |> change()
  end

  def delete_performance!(%Performance{} = performance) do
    Repo.delete!(performance)
  end

  @doc """
  Reschedules performances in the contest based on the given data
  (a list of maps linking performance ids, stage ids and stage times).
  """
  def reschedule_performances(%Contest{} = contest, items) do
    multi =
      Enum.reduce(items, Multi.new(), fn item, acc ->
        %{id: id, stage_id: s_id, stage_time: time} = item

        changeset =
          get_performance!(contest, id)
          |> Performance.stage_changeset(%{stage_id: s_id, stage_time: time})

        Multi.update(acc, id, changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok,
         Enum.map(result, fn
           {id, %Performance{stage_time: stage_time}} -> {id, stage_time}
         end)}

      {:error, failed_p_id, failed_cs, _} ->
        {:error, failed_p_id, failed_cs}
    end
  end

  @doc """
  Publishes the results of all performances with the given ids found in the contest.
  """
  def publish_results(%Contest{} = contest, performance_ids) when is_list(performance_ids) do
    update_results_public(contest, performance_ids, true)
  end

  @doc """
  Unpublishes the results of all performances with the given ids found in the contest.
  """
  def unpublish_results(%Contest{} = contest, performance_ids) when is_list(performance_ids) do
    update_results_public(contest, performance_ids, false)
  end

  def migrate_performances(
        %Contest{host: rw_host, season: season, round: 1} = rw,
        performance_ids,
        %Contest{season: season, round: 2} = lw
      )
      when is_list(performance_ids) do
    # Perform required preloads
    [rw, lw] = Enum.map([rw, lw], &Foundation.load_contest_categories/1)

    # Fetch performances
    performances =
      performances_query(rw.id)
      |> where([p], p.id in ^performance_ids)
      |> without_successor
      |> preload([:pieces, :stage])
      |> Repo.all()

    # Perform migration as single transaction
    multi =
      Enum.reduce(performances, Multi.new(), fn p, acc ->
        case find_matching_cc(p, lw) do
          nil ->
            acc

          target_cc ->
            changeset =
              Performance.migration_changeset(p)
              |> put_assoc(:contest_category, target_cc)
              |> put_assoc(:predecessor, p)
              |> put_assoc(:predecessor_contest, rw)
              |> put_assoc(:predecessor_host, rw_host)

            Multi.insert(acc, p.id, changeset)
        end
      end)

    case Repo.transaction(multi) do
      {:ok, result} -> {:ok, Enum.count(result)}
      {:error, _, _, _} -> :error
    end
  end

  def migrate_performances(%Contest{}, _performance_ids, %Contest{}), do: :error

  @doc """
  Returns the performance's total duration as a Timex.Duration.
  """
  def total_duration(%Performance{pieces: pieces}) do
    pieces
    |> Enum.reduce(Timex.Duration.zero(), fn piece, total ->
      total
      |> Timex.Duration.add(Timex.Duration.from_minutes(piece.minutes))
      |> Timex.Duration.add(Timex.Duration.from_seconds(piece.seconds))
    end)
  end

  @doc """
  Returns data on how many results have been entered/published for the performances.
  """
  def result_completions(performances) do
    result_groups = result_groups(performances)
    with_points = result_groups |> Enum.filter(&has_points?/1)
    public = performances |> Enum.filter(& &1.results_public) |> result_groups

    %{
      total: length(result_groups),
      with_points: length(with_points),
      public: length(public)
    }
  end

  def statistics(performances, 0) do
    appearances = performances |> appearances

    %{
      appearances: length(appearances),
      participants: appearances |> unique_participants |> length,
      performances: %{total: length(performances)}
    }
  end

  def statistics(performances, _round) do
    # Use Kimu stats as base
    statistics(performances, 0)
    |> put_in([:performances, :classical], genre_count(performances, "classical"))
    |> put_in([:performances, :popular], genre_count(performances, "popular"))
  end

  def load_pieces(performances) do
    performances |> Repo.preload(pieces: pieces_query())
  end

  def load_successors(performances) do
    Repo.preload(performances, :successor)
  end

  def load_predecessor_host(%Performance{} = performance) do
    Repo.preload(performance, :predecessor_host)
  end

  def load_predecessor_hosts(performances) when is_list(performances) do
    Repo.preload(performances, :predecessor_host)
  end

  def load_contest_category(%Performance{} = performance) do
    performance |> Repo.preload(contest_category: [:contest, :category])
  end

  @doc """
  Returns the appearances with the given ids from the contest.
  """
  def list_appearances(%Contest{id: contest_id}, appearance_ids) when is_list(appearance_ids) do
    query =
      from a in Appearance,
        join: p in assoc(a, :performance),
        join: cc in assoc(p, :contest_category),
        where: cc.contest_id == ^contest_id,
        where: a.id in ^appearance_ids

    Repo.all(query)
  end

  @doc """
  Assigns the given points (if valid) to each of the appearances.
  """
  def set_points(appearances, points) when is_list(appearances) do
    multi =
      Enum.reduce(appearances, Multi.new(), fn a, acc ->
        changeset = Appearance.result_changeset(a, points)
        Multi.update(acc, a.id, changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, _} -> :ok
      {:error, _, _, _} -> :error
    end
  end

  def list_participants(%Contest{id: contest_id}) do
    Participant
    |> preloaded_from_contest(contest_id)
    |> order_by([pt], [pt.family_name, pt.given_name])
    |> Repo.all()
  end

  def list_orphaned_participants do
    orphaned_participants_query() |> order_by(:updated_at) |> Repo.all()
  end

  def delete_orphaned_participants do
    orphaned_participants_query() |> Repo.delete_all()
  end

  @doc """
  Returns duplicate pairs for the contest's participants.
  Each pair consists of a participant from the contest, followed by a possible duplicate.
  """
  def list_duplicate_participants(%Contest{id: contest_id}) do
    contest_participants = Participant |> from_contest(contest_id)

    query =
      from contest_pt in contest_participants,
        join: earlier_pt in Participant,
        on:
          contest_pt.inserted_at > earlier_pt.inserted_at and
            similar(contest_pt.given_name, earlier_pt.given_name) and
            similar(contest_pt.family_name, earlier_pt.family_name),
        order_by: contest_pt.given_name,
        select: {contest_pt, earlier_pt}

    Repo.all(query)
  end

  def get_participant!(id) do
    query =
      from pt in Participant,
        join: p in assoc(pt, :performances),
        join: cc in assoc(p, :contest_category),
        join: c in assoc(cc, :contest),
        order_by: c.start_date,
        preload: [performances: {p, contest_category: {cc, contest: c}}]

    Repo.get!(query, id)
  end

  def get_participant!(%Contest{id: contest_id}, id) do
    Participant
    |> from_contest(contest_id)
    |> Repo.get!(id)
  end

  def change_participant(%Participant{} = participant) do
    Participant.changeset(participant, %{})
  end

  def update_participant(%Participant{} = participant, attrs) do
    multi =
      Multi.new()
      |> Multi.update(:update_participant, Participant.changeset(participant, attrs))
      |> Multi.run(:fix_age_groups, fn repo, _ ->
        fix_age_groups(participant, repo)
      end)

    case Repo.transaction(multi) do
      {:ok, %{update_participant: participant}} ->
        {:ok, participant}

      {:error, :update_participant, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Replaces the source participant in all their appearances by the target participant,
  merging the given fields' values into the target participant in the process.
  """
  def merge_participants(source_id, target_id, fields_to_merge) do
    source_pt = get_participant!(source_id)
    appearances = Ecto.assoc(source_pt, :appearances)
    merge_map = source_pt |> Map.take(fields_to_merge)

    target_pt = get_participant!(target_id)
    target_changeset = target_pt |> change(merge_map)

    multi =
      Multi.new()
      |> Multi.update(:update_target, target_changeset)
      |> Multi.update_all(:update_appearances, appearances, set: [participant_id: target_id])
      |> Multi.delete(:delete_source, source_pt)
      |> Multi.run(:fix_age_groups, fn repo, _ ->
        fix_age_groups(target_pt, repo)
      end)

    case Repo.transaction(multi) do
      {:ok, _} -> :ok
      {:error, _, _, _} -> :error
    end
  end

  @doc """
  Casts and validates fields that only apply for certain categories, by first retrieving
  the category (either as change or existing data) from the changeset.
  """
  def handle_category_specific_fields(changeset, contest, attrs) do
    with cc_id when not is_nil(cc_id) <- get_field(changeset, :contest_category_id) do
      %{category: c} = Foundation.get_contest_category!(contest, cc_id)

      if c.requires_concept_document do
        changeset
        |> cast(attrs, [:concept_document_url])
        |> validate_required(:concept_document_url)
      else
        changeset
        |> put_change(:concept_document_url, nil)
      end
    else
      _ -> changeset
    end
  end

  @doc """
  Defines a Dataloader source.
  """
  def data do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Performance, %{scope: :result}) do
    # Preload associations needed for result calculation
    Performance |> preload([[contest_category: :contest], :appearances])
  end

  def query(queryable, _), do: queryable

  # Private helpers

  defp performances_query(contest_id) do
    from p in Performance,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      order_by: [p.stage_time, cc.inserted_at, p.age_group, p.inserted_at],
      preload: [
        [contest_category: {cc, :category}],
        [appearances: :participant]
      ]
  end

  defp apply_filter(query, %PerformanceFilter{} = filter) do
    filter_map = PerformanceFilter.to_filter_map(filter)

    Enum.reduce(filter_map, query, fn
      {:stage_date, date}, query ->
        on_date(query, date)

      {:stage_id, s_id}, query ->
        on_stage(query, s_id)

      {:genre, genre}, query ->
        with_genre(query, genre)

      {:predecessor_host_id, h_id}, query ->
        with_predecessor_host(query, h_id)

      {:contest_category_id, cc_id}, query ->
        in_contest_category(query, cc_id)

      {:age_group, ag}, query ->
        with_age_group(query, ag)

      {:results_public, results_public}, query ->
        with_results_public(query, results_public)

      _, query ->
        query
    end)
  end

  defp put_edit_code(%Changeset{valid?: true} = changeset, round) do
    edit_code = :rand.uniform(99999) |> Performance.to_edit_code(round)
    put_change(changeset, :edit_code, edit_code)
  end

  defp put_edit_code(changeset, _round), do: changeset

  defp put_age_groups(%Changeset{valid?: true} = changeset, contest) do
    cc_id = get_field(changeset, :contest_category_id)
    %{groups_accompanists: groups_acc} = Foundation.get_contest_category!(contest, cc_id)
    AgeGroupCalculator.put_age_groups(changeset, contest.season, groups_acc)
  end

  defp put_age_groups(changeset, _contest), do: changeset

  # Attempts to connect nested appearances to participants that already
  # exist in the database, based on certain "identity fields".
  defp stitch_participants(
         %Changeset{
           valid?: true,
           changes: %{appearances: appearances} = changes
         } = changeset
       ) do
    changes = %{changes | appearances: Enum.map(appearances, &stitch_participant/1)}
    %{changeset | changes: changes}
  end

  defp stitch_participants(changeset), do: changeset

  # Connects a to-be-inserted appearance to an existing participant,
  # if one is found for the "new" participant's identity fields.
  # If multiple are found, we pick the "original" (= least recent) one.
  defp stitch_participant(%Changeset{action: :insert} = appearance_cs) do
    pt_cs = get_change(appearance_cs, :participant)
    given_name = get_field(pt_cs, :given_name)
    family_name = get_field(pt_cs, :family_name)
    birthdate = get_field(pt_cs, :birthdate)

    earliest_match =
      Participant
      |> where(given_name: ^given_name)
      |> where(family_name: ^family_name)
      |> where(birthdate: ^birthdate)
      |> order_by(:inserted_at)
      |> limit(1)
      |> Repo.one()

    case earliest_match do
      nil ->
        appearance_cs

      existing_pt ->
        appearance_cs
        |> put_change(:participant, change(existing_pt, pt_cs.changes))
    end
  end

  defp stitch_participant(changeset), do: changeset

  # Attempts to insert a performance changeset into the database.
  # This also handles retries in case the edit code is already taken.
  defp attempt_insert(%Changeset{} = changeset, round) do
    changeset = changeset |> put_edit_code(round)

    case Repo.insert(changeset) do
      {:error, %Changeset{errors: [edit_code: _]}} ->
        # Retry if edit code was invalid
        attempt_insert(changeset, round)

      other_result ->
        other_result
    end
  end

  # Recalculates all age groups affected by the participant's birthdate and persists them in a single transaction.
  defp fix_age_groups(%Participant{} = pt, repo) do
    query =
      from Ecto.assoc(pt, :performances),
        preload: [appearances: :participant, contest_category: :contest]

    repo.all(query)
    |> Enum.reduce(Multi.new(), fn performance, multi ->
      %{contest_category: %{contest: c} = cc} = performance
      changeset = AgeGroupCalculator.fix_age_groups(performance, c.season, cc.groups_accompanists)
      Multi.update(multi, {:update_performance, performance.id}, changeset)
    end)
    |> repo.transaction()
  end

  defp on_date(query, date) do
    from p in query, where: fragment("?::date", p.stage_time) == ^date
  end

  defp on_stage(query, stage_id) do
    from p in query, where: p.stage_id == ^stage_id
  end

  defp with_genre(query, genre) do
    from p in query,
      join: cc in assoc(p, :contest_category),
      join: c in assoc(cc, :category),
      where: c.genre == ^genre
  end

  defp with_predecessor_host(query, h_id) do
    from p in query,
      join: pre_h in assoc(p, :predecessor_host),
      where: pre_h.id == ^h_id
  end

  defp in_contest_category(query, cc_id) do
    from p in query,
      join: cc in assoc(p, :contest_category),
      where: cc.id == ^cc_id
  end

  defp with_age_group(query, age_group) do
    from p in query, where: p.age_group == ^age_group
  end

  defp with_results_public(query, public) do
    from p in query, where: p.results_public == ^public
  end

  defp without_successor(query) do
    from p in query,
      left_join: suc in assoc(p, :successor),
      where: is_nil(suc)
  end

  # Limits the query to the given contest id
  defp from_contest(Participant = query, contest_id) do
    from pt in query,
      join: p in assoc(pt, :performances),
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      distinct: true
  end

  # Limits the query to the given contest id and fully preloads it
  defp preloaded_from_contest(Performance = query, contest_id) do
    from p in query,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      preload: [
        [contest_category: {cc, :category}],
        [appearances: :participant],
        [pieces: ^pieces_query()]
      ]
  end

  defp preloaded_from_contest(Participant = query, contest_id) do
    from pt in query,
      join: p in assoc(pt, :performances),
      left_join: pre_h in assoc(p, :predecessor_host),
      join: cc in assoc(p, :contest_category),
      join: cg in assoc(cc, :category),
      where: cc.contest_id == ^contest_id,
      distinct: true,
      preload: [
        performances:
          {p,
           [
             contest_category: {cc, category: cg},
             predecessor_host: pre_h
           ]}
      ]
  end

  defp update_results_public(contest, performance_ids, public) do
    query =
      from p in Performance,
        join: cc in assoc(p, :contest_category),
        where: cc.contest_id == ^contest.id,
        where: p.id in ^performance_ids

    {count, _} = Repo.update_all(query, set: [results_public: public])
    {:ok, count}
  end

  defp result_groups(performances) do
    performances |> Enum.flat_map(&Performance.result_groups/1)
  end

  defp has_points?(result_group) do
    Enum.all?(result_group, &(!is_nil(&1.points)))
  end

  defp appearances(performances) do
    performances |> Enum.flat_map(& &1.appearances)
  end

  defp unique_participants(appearances) do
    appearances |> Enum.map(& &1.participant) |> Enum.uniq()
  end

  defp genre_count(performances, genre) do
    performances
    |> Enum.map(& &1.contest_category.category)
    |> Enum.filter(&(&1.genre == genre))
    |> length
  end

  defp pieces_query do
    from pc in Piece, order_by: pc.inserted_at
  end

  # Returns the contest category from the target contest that shares a category
  # with the performance's own CC, or nil if no match is found.
  defp find_matching_cc(%Performance{contest_category: cc}, %Contest{} = target_c) do
    Enum.find(target_c.contest_categories, &(&1.category.id == cc.category.id))
  end

  defp orphaned_participants_query do
    from pt in Participant,
      where: fragment("? NOT IN (SELECT participant_id FROM appearances)", pt.id)
  end
end
