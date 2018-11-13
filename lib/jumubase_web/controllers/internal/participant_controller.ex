defmodule JumubaseWeb.Internal.ParticipantController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Participant

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

  def show(conn, %{"id" => id}, contest) do
    participant = Showtime.get_participant!(contest, id)

    conn
    |> assign(:contest, contest)
    |> assign(:participant, participant)
    |> add_contest_breadcrumb(contest)
    |> add_participants_breadcrumb(contest)
    |> add_participant_breadcrumb(contest, participant)
    |> render("show.html")
  end

  # Private helpers

  def add_participant_breadcrumb(conn, %Contest{} = contest, %Participant{} = participant) do
    add_breadcrumb(conn,
      name: full_name(participant),
      path: internal_contest_participant_path(conn, :show, contest, participant)
    )
  end
end
