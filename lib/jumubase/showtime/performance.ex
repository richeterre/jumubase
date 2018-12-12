defmodule Jumubase.Showtime.Performance do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  schema "performances" do
    field :age_group, :string
    field :edit_code, :string
    field :stage_time, :utc_datetime

    belongs_to :contest_category, Foundation.ContestCategory
    has_many :appearances, Appearance, on_replace: :delete
    has_many :participants, through: [:appearances, :participant]
    has_many :pieces, Piece, on_replace: :delete

    timestamps()
  end

  @required_attrs [:contest_category_id]

  @doc false
  def changeset(%Performance{} = performance, attrs) do
    performance
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> cast_assoc(:appearances)
    |> validate_appearances
    |> cast_assoc(:pieces)
    |> validate_pieces
    |> unique_constraint(:edit_code,
      message: dgettext("errors", "must be unique")
    )
  end

  @doc """
  Generates an edit code string of suitable length from a number.
  """
  def to_edit_code(number, round) do
    round_part = round |> Integer.to_string
    number_part = number |> Integer.to_string |> String.pad_leading(5, "0")
    "#{round_part}#{number_part}"
  end

  # Private helpers

  defp validate_appearances(%Changeset{} = changeset) do
    case get_field(changeset, :appearances) do
      [] ->
        add_error(changeset, :base,
          dgettext("errors", "The performance must have at least one participant."))
      appearances ->
        cond do
          has_soloists_and_ensemblists?(appearances) ->
            add_error(changeset, :base,
            dgettext("errors", "The performance can't have both soloists and ensemblists."))
          has_many_soloists?(appearances) ->
            add_error(changeset, :base,
              dgettext("errors", "The performance can't have more than one soloist."))
          has_single_ensemblist?(appearances) ->
            add_error(changeset, :base,
            dgettext("errors", "The performance can't have only one ensemblist."))
          has_only_accompanists?(appearances) ->
            add_error(changeset, :base,
              dgettext("errors", "The performance can't have only accompanists."))
          true ->
            changeset
        end
    end
  end

  defp validate_pieces(%Changeset{} = changeset) do
    case get_field(changeset, :pieces) do
      [] ->
        add_error(changeset, :base,
          dgettext("errors", "The performance must have at least one piece."))
      _ ->
        changeset
    end
  end

  defp has_soloists_and_ensemblists?(a_list) do
    role_count(a_list, "soloist") > 0 and role_count(a_list, "ensemblist") > 0
  end

  defp has_many_soloists?(a_list) do
    role_count(a_list, "soloist") > 1
  end

  defp has_single_ensemblist?(a_list) do
    role_count(a_list, "ensemblist") == 1
  end

  defp has_only_accompanists?(a_list) do
    role_count(a_list, "accompanist") == length(a_list)
  end

  defp role_count(appearance_list, role) do
    appearance_list
    |> Enum.filter(fn a -> a.role == role end)
    |> length
  end
end
