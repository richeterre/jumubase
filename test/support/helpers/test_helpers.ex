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
    assert_ids_match_ordered(Enum.sort(first_list), Enum.sort(second_list))
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
end
