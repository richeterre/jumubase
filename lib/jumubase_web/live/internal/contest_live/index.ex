defmodule JumubaseWeb.Internal.ContestLive.Index do
  use Phoenix.LiveView
  alias Jumubase.Accounts
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("live_list.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns)}
  end

  # Private helpers

  defp prepare(socket, %{"user_id" => user_id}) do
    user = Accounts.get!(user_id)

    contests =
      Contest
      |> Permit.scope_contests(user)
      |> Foundation.list_contests()

    assign(socket, current_user: user, contests: contests)
  end
end
