defmodule Jumubase.TestHelpers do
  import ExUnit.Assertions
  import Jumubase.Utils, only: [get_ids: 1]
  import Jumubase.Factory
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.ContestCategory

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
  Returns all roles except the given one(s).
  """
  def roles_except(role) when is_binary(role) do
    roles_except([role])
  end

  def roles_except(roles) when is_list(roles) do
    all_roles() -- roles
  end

  @doc """
  Returns valid form parameters for a performance,
  using the given contest category.
  """
  def valid_performance_params(%ContestCategory{} = cc) do
    %{
      "performance" => %{
        "contest_category_id" => cc.id,
        "appearances" => %{
          "0" => %{
            "role" => "soloist",
            "instrument" => "piano",
            "participant" => %{
              "given_name" => "A",
              "family_name" => "A",
              "birthdate" => %{
                "year" => 2004,
                "month" => 1,
                "day" => 1
              },
              "email" => "ab@cd.ef",
              "phone" => "1234567"
            }
          }
        },
        "pieces" => %{
          "0" => %{
            "title" => "Title",
            "composer" => "Composer",
            "composer_born" => "1900",
            "epoch" => "e",
            "minutes" => 1,
            "seconds" => 23
          }
        }
      }
    }
  end

  def valid_contest_category_params do
    cg = insert(:category)
    params_for(:contest_category) |> Map.put(:category_id, cg.id)
  end

  # Private helpers

  defp get_sorted_ids(list) do
    list |> get_ids |> Enum.sort()
  end

  defp get_tuple_ids({left, right}) do
    {left.id, right.id}
  end
end
