defmodule JumubaseWeb.Schema.Helpers do
  use Absinthe.Schema.Notation

  @doc """
  Defines a non-nullable list with non-nullable members of the given type.
  """
  def non_null_list_of(type) do
    non_null(list_of(non_null(type)))
  end
end
