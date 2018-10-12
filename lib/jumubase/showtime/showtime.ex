defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  import Ecto.Query
  alias Ecto.Changeset
  alias Jumubase.Repo
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime.AgeGroupCalculator
  alias Jumubase.Showtime.Performance

  def list_performances(%Contest{id: id}) do
    query = from p in Performance,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^id,
      preload: [contest_category: {cc, :category}]

    Repo.all(query)
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

  def create_performance(%Contest{} = contest, attrs \\ %{}) do
    changeset = Performance.changeset(%Performance{}, attrs)

    changeset
    |> put_edit_code
    |> put_age_groups(contest)
    |> Repo.insert()
  end

  def update_performance(%Contest{} = contest, %Performance{} = performance, attrs \\ %{}) do
    performance
    |> Performance.changeset(attrs)
    |> Repo.update

    # TODO: Update age groups
  end

  def change_performance(%Performance{} = performance) do
    performance
    |> Repo.preload([:appearances, :pieces])
    |> Performance.changeset(%{})
  end

  # Private helpers

  defp put_edit_code(%Changeset{valid?: true} = changeset) do
    edit_code = :rand.uniform(999999) |> Performance.to_edit_code
    Changeset.put_change(changeset, :edit_code, edit_code)
  end
  defp put_edit_code(changeset), do: changeset

  defp put_age_groups(%Changeset{valid?: true} = changeset, contest) do
    cc_id = Changeset.get_field(changeset, :contest_category_id)
    %{category: %{genre: genre}} = Foundation.get_contest_category!(contest, cc_id)

    AgeGroupCalculator.put_age_groups(changeset, contest.season, genre)
  end
  defp put_age_groups(changeset, _contest), do: changeset

  # Limits a performance query to the given contest id and fully preloads it
  defp preloaded_from_contest(query, contest_id) do
    from p in query,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^contest_id,
      preload: [
        [contest_category: {cc, :category}],
        [appearances: :participant],
        :pieces
      ]
  end
end
