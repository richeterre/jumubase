defmodule Jumubase.Utils do

  @doc """
  Returns the ids of the given items.
  """
  def get_ids(items), do: Enum.map(items, &(&1.id))
end
