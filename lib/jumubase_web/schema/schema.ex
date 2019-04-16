defmodule JumubaseWeb.Schema do
  use Absinthe.Schema

  # Here is some fake data
  @people [
    %{name: "Annick", shoe_size: 39, favorite_toy: %{name: "iPad"}},
    %{name: "Ben", shoe_size: 22, favorite_toy: %{name: "Bai"}},
    %{name: "Stefan", shoe_size: 46, favorite_toy: %{name: "Frying pan"}}
  ]

  query do
    field :people, :person do
      resolve(fn _, _ -> {:ok, @people} end)
    end
  end

  object :person do
    field :name, :string
    field :shoe_size, :integer
    field :favorite_toy, :toy
  end

  object :toy, description: "Something nice to play with" do
    field :name, :string, description: "What to call the toy"
  end
end
