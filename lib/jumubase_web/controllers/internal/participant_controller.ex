defmodule JumubaseWeb.Internal.ParticipantController do
  use JumubaseWeb, :controller
  alias Jumubase.Showtime

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &internal_contest_path/2, action: :index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, _params, contest) do
    participants = Showtime.list_participants(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:participants, participants)
    |> add_contest_breadcrumb(contest)
    |> add_participants_breadcrumb(contest)
    |> render("index.html")
  end
end
