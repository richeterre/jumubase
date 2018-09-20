defmodule Jumubase.Showtime do
  @moduledoc """
  The boundary for the Showtime system, which manages data related
  to what happens on the competition stage, e.g. performances.
  """

  import Ecto.Query
  alias Ecto.Changeset
  alias Jumubase.Repo
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime.Performance

  def list_performances(%Contest{id: id}) do
    query = from p in Performance,
      join: cc in assoc(p, :contest_category),
      where: cc.contest_id == ^id,
      preload: [contest_category: {cc, :category}]

    Repo.all(query)
  end

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
