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
  Returns all performances from the contest.
  """
  def list_performances(%Contest{id: id}) do
    performances_query(id) |> Repo.all
  end

  @doc """
  Returns all performances from the contest matching the given filter.
  """
  def list_performances(%Contest{id: id}, %PerformanceFilter{} = filter) do
    performances_query(id)
    |> apply_filter(filter)
    |> Repo.all
  end

  @doc """
  Returns the performances with the given ids.
  """
  def list_performances(%Contest{id: contest_id}, performance_ids) when is_list(performance_ids) do
    performances_query(contest_id)
    |> where([p], p.id in ^performance_ids)
    |> Repo.all
  end

  @doc """
  Returns all performances without a stage time from the contest.
  """
  def unscheduled_performances(%Contest{id: id}) do
    performances_query(id)
    |> where([p], is_nil(p.stage_time))
    |> Repo.all
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
  Looks up a performance with the given edit code.

  Returns an error tuple if no performance could be found.
  """
  def lookup_performance(edit_code) do
    case Repo.get_by(Performance, edit_code: edit_code) do
      nil ->
        {:error, :not_found}
      performance ->
        {:ok, Repo.preload(performance, [contest_category: :contest])}
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
  def build_performance(%Contest{round: 1}), do: %Performance{}

  def create_performance(%Contest{} = contest, attrs \\ %{}) do
    Performance.changeset(%Performance{}, attrs)
    |> stitch_participants
    |> put_age_groups(contest)
    |> attempt_insert(contest.round)
  end

  def update_performance(%Contest{} = contest, %Performance{} = performance, attrs \\ %{}) do
    performance
    |> Performance.changeset(attrs)
    |> stitch_participants
    |> put_age_groups(contest)
    |> Repo.update
  end

  def change_performance(%Performance{} = performance) do
    performance
    |> Repo.preload([:appearances, :pieces])
    |> Performance.changeset(%{})
  end

  def delete_performance!(%Performance{} = performance) do
    Repo.delete!(performance)
  end

  @doc """
  Reschedules performances in the contest based on the given data
  (a list of maps linking performance ids, stage ids and stage times).
  """
  def reschedule_performances(%Contest{} = contest, items) do
    multi = Enum.reduce(items, Multi.new, fn item, acc ->
      %{id: id, stage_id: s_id, stage_time: time} = item
      changeset =
        get_performance!(contest, id)
        |> Performance.stage_changeset(%{stage_id: s_id, stage_time: time})
      Multi.update(acc, id, changeset)
    end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok, Enum.map(result, fn
          {id, %Performance{stage_time: stage_time}} -> {id, stage_time}
        end)}
      {:error, failed_p_id, failed_cs, _} ->
        {:error, failed_p_id, failed_cs}
    end
  end

  @doc """
  Returns the performance's total duration as a Timex.Duration.
  """
  def total_duration(%Performance{pieces: pieces}) do
    pieces
    |> Enum.reduce(Timex.Duration.zero, fn piece, total ->
      total
      |> Timex.Duration.add(Timex.Duration.from_minutes(piece.minutes))
      |> Timex.Duration.add(Timex.Duration.from_seconds(piece.seconds))
    end)
  end

  def load_pieces(performances) do
    performances |> Repo.preload(:pieces)
  end

  def load_contest_category(%Performance{} = performance) do
    performance |> Repo.preload(contest_category: [:contest, :category])
  end

  def list_participants(%Contest{id: contest_id}) do
    Participant
    |> preloaded_from_contest(contest_id)
    |> order_by([pt], [pt.family_name, pt.given_name])
    |> Repo.all
  end

  def get_participant!(%Contest{id: contest_id}, id) do
    Participant
    |> from_contest(contest_id)
    |> Repo.get!(id)
  end

  # Private helpers

  defp performances_query(contest_id) do
    from p in Performance,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      order_by: [p.stage_time, cc.inserted_at, p.age_group, p.inserted_at],
      preload: [
        [contest_category: {cc, :category}],
        [appearances: :participant],
        :stage
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
    %{category: %{genre: genre}} = Foundation.get_contest_category!(contest, cc_id)

    AgeGroupCalculator.put_age_groups(changeset, contest.season, genre)
  end
  defp put_age_groups(changeset, _contest), do: changeset

  # Attempts to connect nested appearances to participants that already
  # exist in the database, based on certain "identity fields".
  defp stitch_participants(%Changeset{
    valid?: true, changes: %{appearances: appearances} = changes
  } = changeset) do
    changes = %{changes | appearances: Enum.map(appearances, &stitch_participant/1)}
    %{changeset | changes: changes}
  end
  defp stitch_participants(changeset), do: changeset

  # Connects a to-be-inserted appearance to an existing participant,
  # if one is found for the "new" participant's identity fields.
  defp stitch_participant(%Changeset{action: :insert} = appearance_cs) do
    pt_cs = get_change(appearance_cs, :participant)
    given_name = get_field(pt_cs, :given_name)
    family_name = get_field(pt_cs, :family_name)
    birthdate = get_field(pt_cs, :birthdate)

    case Repo.get_by(Participant, given_name: given_name, family_name: family_name, birthdate: birthdate) do
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
    pieces_query = from pc in Piece, order_by: pc.inserted_at

    from p in query,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      preload: [
        [contest_category: {cc, :category}],
        [appearances: :participant],
        [pieces: ^pieces_query],
      ]
  end
  defp preloaded_from_contest(Participant = query, contest_id) do
    from pt in query,
      join: p in assoc(pt, :performances),
      join: cc in assoc(p, :contest_category),
      join: cg in assoc(cc, :category),
      where: cc.contest_id == ^contest_id,
      distinct: true,
      preload: [performances: {p, contest_category: {cc, category: cg}}]
  end
end
