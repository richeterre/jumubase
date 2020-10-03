defmodule JumubaseWeb.PerformanceController do
  use JumubaseWeb, :controller
  alias Jumubase.Showtime

  # Authorize nested contest, then pass it to all actions
  def action(conn, _) do
    if action_name(conn) == :edit do
      contest_deadline_check_action(conn, __MODULE__)
    else
      contest_openness_check_action(conn, __MODULE__)
    end
  end

  def new(conn, _params, contest) do
    conn
    |> assign(:contest, contest)
    |> render("new.html")
  end

  def edit(conn, %{"edit_code" => edit_code}, contest) do
    performance = Showtime.lookup_performance!(contest, edit_code)

    conn
    |> assign(:contest, contest)
    |> assign(:performance, performance)
    |> render("edit.html")
  end
end
