defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  alias Ecto.Changeset
  alias Jumubase.Repo
  alias Jumubase.Showtime.Performance

  def create_performance(attrs \\ %{}) do
    %Performance{}
    |> Performance.changeset(attrs)
    |> put_edit_code
    |> Repo.insert()
    # TODO: Retry while edit code is taken
    # TODO: Calculate age group
  end

  def change_performance(%Performance{} = performance) do
    Performance.changeset(performance, %{})
  end

  # Private helpers

  defp put_edit_code(%Changeset{} = changeset) do
    edit_code = :rand.uniform(999999) |> Performance.to_edit_code
    Changeset.put_change(changeset, :edit_code, edit_code)
  end
end
