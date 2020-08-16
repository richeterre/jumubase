defmodule Jumubase.Showtime.AgeGroupCalculator do
  alias Ecto.Changeset
  alias Jumubase.Foundation.AgeGroups

  @doc """
  Sets age groups for appearances inside the `changeset`.
  When `group_accompanists` is true, accompanists receive a shared age group.
  """
  def put_age_groups(%Changeset{} = changeset, season, group_accompanists) do
    case Changeset.get_change(changeset, :appearances) do
      nil ->
        changeset

      appearances ->
        # TODO: Avoid this calculation by grabbing age group from soloist or ensemblist
        performance_age_group =
          appearances
          # Grab all non-accompanist appearances from nested changeset
          |> exclude_obsolete
          |> filter_roles(["soloist", "ensemblist"])
          # Calculate joint age group for them
          |> get_birthdates
          |> AgeGroups.calculate_age_group(season)

        changeset
        |> Changeset.put_change(:age_group, performance_age_group)
        |> Changeset.update_change(:appearances, fn changesets ->
          changesets
          |> exclude_obsolete()
          |> put_appearance_age_groups(season, group_accompanists)
        end)
    end
  end

  # Private helpers

  defp put_appearance_age_groups(changesets, season, group_accompanists) do
    changesets
    |> put_individual_age_groups("soloist", season)
    |> put_joint_age_groups("ensemblist", season)
    |> put_accompanist_age_groups(season, group_accompanists)
  end

  # Assigns accompanist age groups either individually or joint, depending on genre.
  defp put_accompanist_age_groups(changesets, season, _group_accompanists = false) do
    put_individual_age_groups(changesets, "accompanist", season)
  end

  defp put_accompanist_age_groups(changesets, season, _group_accompanists = true) do
    put_joint_age_groups(changesets, "accompanist", season)
  end

  # Assigns an individual age group to every appearance changeset with the given role.
  defp put_individual_age_groups(changesets, role, season) do
    Enum.map(changesets, fn cs ->
      if has_role?(cs, role) do
        birthdate = get_birthdate(cs)
        age_group = AgeGroups.calculate_age_group(birthdate, season)
        Changeset.put_change(cs, :age_group, age_group)
      else
        cs
      end
    end)
  end

  # Assigns a joint age group to all appearance changesets with the given role.
  defp put_joint_age_groups(changesets, role, season) do
    case get_birthdates(changesets, role) do
      [] ->
        changesets

      birthdates ->
        Enum.map(changesets, fn cs ->
          if has_role?(cs, role) do
            joint_age_group = AgeGroups.calculate_age_group(birthdates, season)
            Changeset.put_change(cs, :age_group, joint_age_group)
          else
            cs
          end
        end)
    end
  end

  # Grabs participant birthdates for the given role from the given appearance changesets.
  defp get_birthdates(changesets, role) do
    changesets |> filter_roles([role]) |> get_birthdates
  end

  # Grabs all participant birthdates from the given appearance changesets.
  # Note that obsolete changesets won't be taken into account.
  defp get_birthdates(changesets) do
    changesets |> exclude_obsolete |> Enum.map(&get_birthdate/1)
  end

  # Grabs the participant birthdate from the given appearance changeset.
  defp get_birthdate(changeset) do
    Changeset.get_field(changeset, :participant).birthdate
  end

  # Excludes appearances that are not being inserted or updated.
  defp exclude_obsolete(changesets) do
    Enum.filter(changesets, &(&1.action in [:insert, :update]))
  end

  # Returns only appearance changesets with one of the given roles.
  defp filter_roles(changesets, roles) do
    Enum.filter(changesets, fn cs ->
      Changeset.get_field(cs, :role) in roles
    end)
  end

  # Returns whether an appearance changeset has the given role.
  defp has_role?(%Changeset{} = changeset, role) do
    Changeset.get_field(changeset, :role) == role
  end
end
