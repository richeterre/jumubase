defmodule Jumubase.Showtime.Performance do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime.{Appearance, Performance}

  schema "performances" do
    field :age_group, :string
    field :edit_code, :string

    belongs_to :contest_category, Foundation.ContestCategory
    has_many :appearances, Appearance

    timestamps()
  end

  @required_attrs [:contest_category_id]

  @doc false
  def changeset(%Performance{} = performance, attrs) do
    performance
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> cast_assoc(:appearances)
    |> validate_appearance_combinations
  end

  @doc """
  Generates an edit code string of suitable length from a number.
  """
  def to_edit_code(number) when is_integer(number) do
    number |> Integer.to_string |> String.pad_leading(6, "0")
  end

  # Private helpers

  defp validate_appearance_combinations(%Changeset{} = changeset) do
    appearances = get_field(changeset, :appearances)
    cond do
      length(appearances) == 0 ->
        add_error(changeset, :base,
          dgettext("errors", "The performance must have at least one participant"))
      true ->
        changeset
    end
  end
end
