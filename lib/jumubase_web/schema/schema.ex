defmodule JumubaseWeb.Schema do
  use Absinthe.Schema
  alias JumubaseWeb.{ContestResolver, PerformanceResolver}

  import_types Absinthe.Type.Custom

  query do
    field :contests, non_null_list_of(:contest) do
      description "The contests with public timetables."
      resolve &ContestResolver.public_contests/2
    end

    field :performances, non_null_list_of(:performance) do
      arg :contest_id, non_null(:id)
      arg :date, non_null(:date)
      description "The performances of a contest."
      resolve &PerformanceResolver.performances/2
    end
  end

  object :contest do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The contest’s name containing the round, year and host."
      resolve &ContestResolver.name/2
    end

    field :country_code, :string do
      description "The country code of the contest's host."
      resolve &ContestResolver.country_code/2
    end

    field :dates, non_null_list_of(:date) do
      resolve &ContestResolver.dates/2
    end

    field :stages, non_null_list_of(:stage) do
      resolve &ContestResolver.stages/2
    end

    field :start_date, non_null(:date) do
      description "The first day of the contest."
    end

    field :end_date, non_null(:date) do
      description "The last day of the contest."
    end
  end

  object :performance do
    field :id, non_null(:id)

    field :stage_time, non_null(:string) do
      resolve &PerformanceResolver.stage_time/2
    end

    field :category_info, non_null(:string) do
      description "The performance's contest category and age group."
      resolve &PerformanceResolver.category_info/2
    end

    field :appearances, non_null_list_of(:string) do
      description "The performance's appearances."
      resolve &PerformanceResolver.appearances/2
    end
  end

  object :stage do
    field :id, non_null(:id)

    field :name, non_null(:string)
  end

  # Internal helpers

  defp non_null_list_of(type) do
    non_null(list_of(non_null(type)))
  end
end
