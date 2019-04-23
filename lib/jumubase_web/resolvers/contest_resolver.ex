defmodule JumubaseWeb.ContestResolver do
  alias JumubaseWeb.Internal.ContestView

  def public_contests(_, _) do
    {:ok, Jumubase.Foundation.list_public_contests()}
  end

  def name(_args, %{source: contest}) do
    {:ok, ContestView.name(contest)}
  end
end
