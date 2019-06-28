defmodule JumubaseWeb.Schema do
  use Absinthe.Schema
  import JumubaseWeb.Schema.Helpers
  alias Jumubase.Showtime
  alias JumubaseWeb.{ContestResolver, PerformanceResolver}

  import_types Absinthe.Type.Custom
  import_types JumubaseWeb.Schema.Objects

  query do
    field :contests, non_null_list_of(:contest) do
      description "The contests with public timetables."
      resolve &ContestResolver.public_contests/2
    end

    field :performances, list_of(non_null(:performance)) do
      description "The scheduled performances of a public contest."
      arg :contest_id, non_null(:id)
      arg :filter, :performance_filter
      resolve &PerformanceResolver.performances/2
    end

    field :performance, :performance do
      description "A single performance that's scheduled in a public contest."
      arg :id, non_null(:id)
      resolve &PerformanceResolver.performance/2
    end
  end

  @doc """
  Sets up a dataloader for fetching batched data, to avoid n+1 queries.
  """
  def dataloader do
    Dataloader.new()
    |> Dataloader.add_source(Showtime, Showtime.data())
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
