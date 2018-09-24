defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  import Ecto.Query
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
    changeset = Performance.changeset(%Performance{}, attrs)

    # Retrieve genre if a contest category was given
    genre = case changeset do
      %{valid?: true, changes: %{contest_category_id: cc_id}} ->
        # Raises error if contest category is not in given contest
        %{category: category} = Foundation.get_contest_category!(contest, cc_id)
        category.genre
      _ ->
        nil
    end

    changeset
    |> put_edit_code
    |> put_age_groups(contest.season, genre)
    |> Repo.insert()
  end

  def change_performance(%Performance{} = performance) do
    Performance.changeset(performance, %{})
  end

  # Private helpers

  defp put_edit_code(%Changeset{valid?: true} = changeset) do
    edit_code = :rand.uniform(999999) |> Performance.to_edit_code
    Changeset.put_change(changeset, :edit_code, edit_code)
  end
  defp put_edit_code(changeset), do: changeset

  defp put_age_groups(%Changeset{valid?: true} = changeset, season, genre) do
    # TODO: Avoid this calculation by grabbing age group from soloist or ensemblist
    performance_age_group =
      changeset
      # Grab all non-accompanist appearances from nested changeset
      |> Changeset.get_change(:appearances)
      |> filter_roles(["soloist", "ensemblist"])
      # Calculate joint age group for them
      |> get_birthdates
      |> AgeGroups.calculate_age_group(season)

    changeset
    |> Changeset.put_change(:age_group, performance_age_group)
    |> Changeset.update_change(:appearances, &(put_appearance_age_groups(&1, season, genre)))
  end
  defp put_age_groups(changeset, _season, _genre), do: changeset

  defp put_appearance_age_groups(changesets, season, genre) do
    changesets
    |> put_individual_age_group("soloist", season)
    |> put_joint_age_group("ensemblist", season)
    |> put_accompanist_age_groups(season, genre)
  end

  # Assigns accompanist age groups either individually or joint, depending on genre.
  defp put_accompanist_age_groups(changesets, season, "classical") do
    put_individual_age_group(changesets, "accompanist", season)
  end
  defp put_accompanist_age_groups(changesets, season, "popular") do
    put_joint_age_group(changesets, "accompanist", season)
  end

  # Assigns an individual age group to every appearance changeset with the given role.
  defp put_individual_age_group(changesets, role, season) do
    changesets
    |> Enum.map(fn
      %{changes: %{participant_role: ^role}} = cs ->
        %{changes: %{participant: %{changes: %{birthdate: birthdate}}}} = cs
        age_group = AgeGroups.calculate_age_group(birthdate, season)
        Changeset.put_change(cs, :age_group, age_group)
      other ->
        other
    end)
  end

  # Assigns a joint age group to all appearance changesets with the given role.
  defp put_joint_age_group(changesets, role, season) do
    case get_birthdates(changesets, role) do
      [] ->
        changesets
      birthdates ->
        changesets
        |> Enum.map(fn
          %{changes: %{participant_role: ^role}} = cs ->
            joint_age_group = AgeGroups.calculate_age_group(birthdates, season)
            Changeset.put_change(cs, :age_group, joint_age_group)
          other ->
            other
        end)
    end
  end

  # Grabs participant birthdates for the given role from the given appearance changesets.
  defp get_birthdates(changesets, role) do
    changesets |> filter_roles([role]) |> get_birthdates
  end

  # Grabs all participant birthdates from the given appearance changesets.
  defp get_birthdates(changesets) do
    Enum.map(changesets, &(&1.changes.participant.changes.birthdate))
  end

  # Returns only appearance changesets with one of the given roles.
  defp filter_roles(changesets, roles) do
    Enum.filter(changesets, &(&1.changes.participant_role in roles))
  end
end
