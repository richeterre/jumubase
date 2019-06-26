defmodule JumubaseWeb.Schema.Objects do
  use Absinthe.Schema.Notation
  import JumubaseWeb.Schema.Helpers
  alias JumubaseWeb.{AppearanceResolver, ContestResolver, PerformanceResolver}

  object :appearance do
    field :id, non_null(:id)

    field :participant_name, non_null(:string) do
      description "The full name of the appearance's participant."
      resolve &AppearanceResolver.participant_name/2
    end

    field :instrument_name, non_null(:string) do
      description "The name of the participant's instrument in this appearance."
      resolve &AppearanceResolver.instrument_name/2
    end
  end

  object :contest do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The contest’s name containing the round, year and host."
      resolve &ContestResolver.name/2
    end

    field :country_code, non_null(:string) do
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

    field :appearances, non_null_list_of(:appearance) do
      description "The performance's appearances."
      resolve &PerformanceResolver.appearances/2
    end
  end

  object :stage do
    field :id, non_null(:id)

    field :name, non_null(:string)
  end

  input_object :performance_filter do
    field :stage_date, :date
    field :stage_id, :id
  end
end
