defmodule JumubaseWeb.Schema do
  use Absinthe.Schema

  # Here is some fake data
  @people [
    %{name: "Annick", shoe_size: 39, favorite_toy: %{name: "iPad"}},
    %{name: "Ben", shoe_size: 22, favorite_toy: %{name: "Bai"}},
    %{name: "Stefan", shoe_size: 46, favorite_toy: %{name: "Frying pan"}}
  ]

  query do
    field :people, non_null_list_of(:person) do
      resolve(fn _, _ -> {:ok, @people} end)
    end
  end

  object :person do
    field :name, non_null(:string)
    field :shoe_size, non_null(:integer)
    field :favorite_toy, non_null(:toy)
  end

  object :toy, description: "Something nice to play with" do
    field :name, non_null(:string), description: "What to call the toy"
  end

  # Internal helpers

  defp non_null_list_of(type) do
    non_null(list_of(non_null(type)))
  end
end
