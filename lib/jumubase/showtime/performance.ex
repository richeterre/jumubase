defmodule Jumubase.Showtime.Performance do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.Foundation.{ContestCategory, Stage}
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  schema "performances" do
    field :age_group, :string
    field :edit_code, :string
    field :stage_time, :naive_datetime
    field :results_public, :boolean, read_after_writes: true

    belongs_to :contest_category, ContestCategory
    belongs_to :stage, Stage
    has_many :appearances, Appearance, on_replace: :delete
    has_many :participants, through: [:appearances, :participant]
    has_many :pieces, Piece, on_replace: :delete

    timestamps()
  end

  @registration_attrs [:contest_category_id]
  @stage_attrs [:stage_id, :stage_time]

  @doc """
  Allows registering (and updating) a performance.
  """
  def changeset(%Performance{} = performance, attrs) do
    performance
    |> cast(attrs, @registration_attrs)
    |> validate_required(@registration_attrs)
    |> cast_assoc(:appearances)
    |> validate_appearances
    |> cast_assoc(:pieces)
    |> validate_pieces
    |> unique_constraint(:edit_code,
      message: dgettext("errors", "must be unique")
    )
  end

  @doc """
  Allows setting a performance's stage and stage time.
  """
  def stage_changeset(%Performance{} = performance, attrs) do
    performance
    |> cast(attrs, @stage_attrs)
    |> validate_stage_fields
  end

  @doc """
  Generates an edit code string of suitable length from a number.
  """
  def to_edit_code(number, round) do
    round_part = round |> Integer.to_string
    number_part = number |> Integer.to_string |> String.pad_leading(5, "0")
    "#{round_part}#{number_part}"
  end

  @doc """
  Returns the performance's soloist and ensemblist appearances.
  """
  def non_accompanists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &!Appearance.is_accompanist(&1))
  end

  @doc """
  Returns the performance's accompanist appearances.
  """
  def accompanists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.is_accompanist/1)
  end

  @doc """
  Returns the performance's appearances grouped in nested lists,
  based on which ones share a common result (as do e.g. ensemblists and pop accompanists).
  """
  def grouped_appearances(%Performance{contest_category: cc} = p) do
    non_acc = non_accompanists(p)
    acc = accompanists(p)

    case {acc, cc.category.genre} do
      {[], _} -> [non_acc]
      {acc, "popular"} -> [non_acc] ++ [acc]
      {acc, _} -> [non_acc] ++ Enum.chunk_every(acc, 1)
    end
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

  defp validate_stage_fields(%Changeset{} = changeset) do
    stage_id = get_field(changeset, :stage_id)
    stage_time = get_field(changeset, :stage_time)

    cond do
      :erlang.xor(!!stage_id, !!stage_time) ->
        add_error(changeset, :base,
        dgettext("errors", "The performance can either have both stage and stage time, or neither."))
      true ->
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
