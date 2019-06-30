defmodule JumubaseWeb.FoundationResolver do
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.ContestView

  def public_contests(_, _, _) do
    {:ok, Foundation.list_public_contests()}
  end

  def name(%Contest{} = c, _, _) do
    {:ok, ContestView.name(c)}
  end

  def country_code(%Contest{} = c, _, _) do
    {:ok, c.host.country_code}
  end

  def dates(%Contest{} = c, _, _) do
    {:ok, Foundation.date_range(c) |> Enum.to_list()}
  end

  def stages(%Contest{} = c, _, _) do
    {:ok, c.host.stages}
  end
end
