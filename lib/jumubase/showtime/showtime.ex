defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  import Ecto.Query
  import Jumubase.Gettext
  import Jumubase.Utils, only: [get_ids: 1]
  alias Ecto.Changeset
  alias Jumubase.Repo
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest}
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
    |> join(:left, [p], cc in assoc(p, :contest_category))
    |> where([_, cc], cc.contest_id == ^contest_id)
    |> preload([_, cc], [contest_category: {cc, :category}])
    |> preload([_, _], [appearances: :participant])
    |> Repo.get!(id)
  end

  def create_performance(%Contest{} = contest, attrs \\ %{}) do
    %{contest_categories: ccs} = Foundation.load_contest_categories(contest)
    changeset = Performance.changeset(%Performance{}, attrs)

    # Check whether contest category is in given contest
    if Changeset.get_change(changeset, :contest_category_id) in get_ids(ccs) do
      changeset
      |> put_edit_code
      |> put_age_group(contest.season)
      |> Repo.insert()
    else
      changeset =
        changeset
        |> Changeset.add_error(:contest_category_id, gettext("is not in given contest"))
      {:error, changeset}
    end
  end

  def change_performance(%Performance{} = performance) do
    Performance.changeset(performance, %{})
  end

  # Private helpers

  defp put_edit_code(%Changeset{} = changeset) do
    edit_code = :rand.uniform(999999) |> Performance.to_edit_code
    Changeset.put_change(changeset, :edit_code, edit_code)
  end

  defp put_age_group(%Changeset{valid?: true} = changeset, season) do
    age_group =
      changeset
      # Grab all non-accompanist appearances from nested changeset
      |> Changeset.get_change(:appearances)
      |> Enum.filter(&Changeset.get_change(&1, :participant_role) != "accompanist")
      # Calculate joint age group for them
      |> Enum.map(&Changeset.get_change(&1, :participant))
      |> Enum.map(&Changeset.get_change(&1, :birthdate))
      |> AgeGroups.calculate_age_group(season)

    Changeset.put_change(changeset, :age_group, age_group)
  end
  defp put_age_group(changeset, _season), do: changeset
end
