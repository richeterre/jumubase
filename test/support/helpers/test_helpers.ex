defmodule Jumubase.TestHelpers do
  import ExUnit.Assertions

  @doc """
  Returns whether the ids of the lists' elements match in that order.
  """
  def assert_ids_match_ordered(first_list, second_list) do
    assert get_ids(first_list) == get_ids(second_list)
  end

  @doc """
  Returns whether the ids of the lists' elements match, ignoring order.
  """
  def assert_ids_match_unordered(first_list, second_list) do
    assert_ids_match_ordered(Enum.sort(first_list), Enum.sort(second_list))
  end

  @doc """
  Extracts the ids from a list of items.
  """
  def get_ids(list) do
    Enum.map(list, &(&1.id))
  end
end
