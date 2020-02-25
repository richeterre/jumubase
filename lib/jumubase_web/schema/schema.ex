defmodule JumubaseWeb.Schema do
  use Absinthe.Schema
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias JumubaseWeb.{FoundationResolver, ShowtimeResolver}

  import_types Absinthe.Type.Custom
  import_types JumubaseWeb.Schema.Objects

  query do
    field :contests, non_null(list_of(non_null(:contest))) do
      description "The contests with public timetables."
      resolve &FoundationResolver.contests/3
    end

    field :featured_contests, non_null(list_of(non_null(:contest))) do
      description "The public contests that are currently featured."
      arg :limit, non_null(:integer)
      resolve &FoundationResolver.featured_contests/3
    end

    field :contest_categories, list_of(non_null(:contest_category)) do
      description "The contest categories of a public contest."
      arg :contest_id, non_null(:id)
      resolve &FoundationResolver.contest_categories/3
    end

    field :performances, list_of(non_null(:performance)) do
      description "The scheduled performances of a public contest."
      arg :contest_id, non_null(:id)
      arg :filter, :performance_filter
      resolve &ShowtimeResolver.performances/3
    end

    field :performance, :performance do
      description "A single performance that's scheduled in a public contest."
      arg :id, non_null(:id)
      resolve &ShowtimeResolver.performance/3
    end
  end

  @doc """
  Sets up a dataloader for fetching batched data, to avoid n+1 queries.
  """
  def dataloader do
    Dataloader.new()
    |> Dataloader.add_source(Foundation, Foundation.data())
    |> Dataloader.add_source(Showtime, Showtime.data())
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
