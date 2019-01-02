defmodule Jumubase.Showtime.PerformanceFilter do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.Showtime.PerformanceFilter

  @primary_key false

  embedded_schema do
    field :stage_date, :date, default: nil
    field :stage_id, :id, default: nil
    field :genre, :string, default: nil
    field :contest_category_id, :id, default: nil
    field :age_group, :string, default: nil
    field :results_public, :boolean, default: nil
  end

  @doc """
  Creates a filter changeset from the given params.
  """
  def changeset(params) do
    %PerformanceFilter{}
    |> cast(params,
      [:stage_date, :stage_id, :genre, :contest_category_id, :age_group, :results_public]
    )
  end

  @doc """
  Creates a filter struct from the given params.
  """
  def from_params(params) do
    changeset(params) |> apply_changes
  end

  @doc """
  Returns whether the filter contains any set values.
  """
  def active?(%PerformanceFilter{} = filter) do
    filter |> to_filter_map |> Enum.empty? |> Kernel.not
  end

  @doc """
  Converts the filter into a map with non-set (nil) values removed.
  """
  def to_filter_map(%PerformanceFilter{} = filter) do
    filter
    |> Map.from_struct
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new
  end
end
