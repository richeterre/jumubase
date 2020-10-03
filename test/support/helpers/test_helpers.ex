defmodule Jumubase.TestHelpers do
  import ExUnit.Assertions
  import Jumubase.Utils, only: [get_ids: 1]
  alias Jumubase.JumuParams

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
    assert get_sorted_ids(first_list) == get_sorted_ids(second_list)
  end

  @doc """
  Returns whether the ids of the lists' tuple elements match in that order.
  """
  def assert_tuple_ids_match_ordered(first_list, second_list) do
    assert Enum.map(first_list, &get_tuple_ids/1) == Enum.map(second_list, &get_tuple_ids/1)
  end

  @doc """
  Returns all user roles.
  """
  def all_roles, do: JumuParams.user_roles()

  @doc """
  Returns all roles except the given one.
  """
  def roles_except(role) when is_binary(role) do
    roles_except([role])
  end

  @doc """
  Returns all roles except the given ones.
  """
  def roles_except(roles) when is_list(roles) do
    all_roles() -- roles
  end

  # Private helpers

  defp get_sorted_ids(list) do
    list |> get_ids |> Enum.sort()
  end

  defp get_tuple_ids({left, right}) do
    {left.id, right.id}
  end
end
