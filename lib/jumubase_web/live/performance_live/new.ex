defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance}

  def render(assigns) do
    Phoenix.View.render(JumubaseWeb.PerformanceView, "live_form.html", assigns)
  end

  def mount(_params, %{"contest_id" => c_id}, socket) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

    changeset =
      Showtime.build_performance(contest)
      |> Showtime.change_performance()

    {:ok,
     assign(socket,
       changeset: changeset,
       contest: contest,
       contest_category_options:
         contest.contest_categories |> Enum.map(&{&1.category.name, &1.id})
     )}
  end

  def handle_event("change", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add-appearance", _, socket) do
    changeset = socket.assigns.changeset |> append_appearance()
    {:noreply, assign(socket, changeset: changeset)}
  end

  defp append_appearance(changeset) do
    existing_appearances = Map.get(changeset.changes, :appearances, [])

    appearances =
      existing_appearances
      |> Enum.concat([%Appearance{}])

    changeset
    |> Ecto.Changeset.put_assoc(:appearances, appearances)
  end
end
