defmodule JumubaseWeb.Schema do
  use Absinthe.Schema
  alias JumubaseWeb.ContestResolver

  import_types Absinthe.Type.Custom

  query do
    field :contests, non_null_list_of(:contest) do
      description "The contests with public timetables."
      resolve &ContestResolver.public_contests/2
    end
  end

  object :contest do
    field :id, :id

    field :name, :string do
      description "The contest’s name containing the round, year and host."
      resolve &ContestResolver.name/2
    end

    field :start_date, :date do
      description "The first day of the contest."
    end

    field :end_date, :date do
      description "The last day of the contest."
    end
  end

  # Internal helpers

  defp non_null_list_of(type) do
    non_null(list_of(non_null(type)))
  end
end
