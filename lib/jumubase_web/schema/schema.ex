defmodule JumubaseWeb.Schema do
  use Absinthe.Schema
  import JumubaseWeb.Schema.Helpers
  alias JumubaseWeb.{ContestResolver, PerformanceResolver}

  import_types(Absinthe.Type.Custom)
  import_types(JumubaseWeb.Schema.Objects)

  query do
    field :contests, non_null_list_of(:contest) do
      description("The contests with public timetables.")
      resolve(&ContestResolver.public_contests/2)
    end

    field :performances, non_null_list_of(:performance) do
      description("The performances of a contest.")
      arg(:contest_id, non_null(:id))
      arg(:filter, :performance_filter)
      resolve(&PerformanceResolver.performances/2)
    end
  end
end
