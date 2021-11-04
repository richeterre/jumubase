defmodule Jumubase.Foundation.ContestFilter do
  use Ecto.Schema
  alias Ecto.Changeset
  alias Jumubase.Foundation.ContestFilter

  @primary_key false

  embedded_schema do
    field :season, :integer, default: nil
    field :round, :integer, default: nil
    field :grouping, :string, default: nil
    field :search_text, :string, default: nil
  end

  @doc """
  Convers the filter into a changeset.
  """
  def change(%ContestFilter{} = filter) do
    Changeset.change(filter)
  end

  @doc """
  Creates a filter changeset from the given params.
  """
  def changeset(params) do
    %ContestFilter{}
    |> Changeset.cast(params, ContestFilter.__schema__(:fields))
  end

  @doc """
  Creates a filter struct from the given params.
  """
  def from_params(params) do
    changeset(params) |> Changeset.apply_changes()
  end

  @doc """
  Converts the filter into a map with non-set (nil) values removed.
  """
  def to_filter_map(%ContestFilter{} = filter) do
    filter
    |> Map.from_struct()
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new()
  end
end
