defmodule JumubaseWeb.Internal.ParticipantController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  alias Ecto.Changeset
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Participant
  alias Jumubase.Mailer
  alias Jumubase.Utils
  alias JumubaseWeb.Internal.ContestLive
  alias JumubaseWeb.Email

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Contests"),
    path_fun: &Routes.internal_live_path/2,
    action: ContestLive.Index

  plug :admin_check when action in [:compare, :merge, :send_welcome_emails]

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
    |> add_breadcrumbs(contest, participant)
    |> render("show.html")
  end

  def edit(conn, %{"id" => id}, contest) do
    participant = Showtime.get_participant!(contest, id)
    changeset = Showtime.change_participant(participant)

    render_edit_form(conn, contest, participant, changeset)
  end

  def update(conn, %{"id" => id, "participant" => participant_params}, contest) do
    participant = Showtime.get_participant!(contest, id)

    case Showtime.update_participant(participant, participant_params) do
      {:ok, participant} ->
        name = full_name(participant)

        conn
        |> put_flash(:info, gettext("The participant %{name} was updated.", name: name))
        |> redirect(to: Routes.internal_contest_participant_path(conn, :index, contest))

      {:error, %Changeset{} = changeset} ->
        render_edit_form(conn, contest, participant, changeset)
    end
  end

  def duplicates(conn, _params, contest) do
    duplicate_pairs = Showtime.list_duplicate_participants(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:pairs, duplicate_pairs)
    |> add_contest_breadcrumb(contest)
    |> add_participants_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Duplicates"), path: current_path(conn))
    |> render("duplicates.html")
  end

  def compare(conn, %{"source_id" => source_id, "target_id" => target_id}, contest) do
    source_pt = Showtime.get_participant!(source_id)
    target_pt = Showtime.get_participant!(target_id)

    conn
    |> assign(:contest, contest)
    |> assign(:source, source_pt)
    |> assign(:target, target_pt)
    |> add_contest_breadcrumb(contest)
    |> add_participants_breadcrumb(contest)
    |> add_breadcrumb(
      name: gettext("Duplicates"),
      path: Routes.internal_contest_participant_path(conn, :duplicates, contest)
    )
    |> add_breadcrumb(name: full_name(source_pt), path: current_path(conn))
    |> render("compare.html")
  end

  def merge(conn, params, contest) do
    %{"source_id" => source_id, "target_id" => target_id, "merge_fields" => merge_fields} = params
    fields_to_merge = extract_merge_field_atoms(merge_fields)

    conn =
      case Showtime.merge_participants(source_id, target_id, fields_to_merge) do
        :ok ->
          put_flash(conn, :success, gettext("The participants were merged."))

        :error ->
          put_flash(conn, :error, gettext("The participants could not be merged."))
      end

    redirect(conn, to: Routes.internal_contest_participant_path(conn, :duplicates, contest))
  end

  def export_csv(conn, _params, contest) do
    participants = Showtime.list_participants(contest)
    csv_data = JumubaseWeb.CSVEncoder.encode(participants, contest.round)

    conn
    |> send_download({:binary, csv_data},
      content_type: "application/csv",
      filename: "Teilnehmende.csv"
    )
  end

  def send_welcome_emails(conn, _params, contest) do
    contest
    |> Email.welcome_advanced()
    |> Enum.each(&Mailer.deliver/1)

    conn
    |> put_flash(:success, gettext("The welcome emails were sent."))
    |> redirect(to: Routes.internal_contest_participant_path(conn, :index, contest))
  end

  # Private helpers

  defp render_edit_form(
         conn,
         %Contest{} = contest,
         %Participant{} = participant,
         %Changeset{} = changeset
       ) do
    edit_path = Routes.internal_contest_path(conn, :edit, contest)

    conn
    |> assign(:contest, contest)
    |> assign(:participant, participant)
    |> assign(:changeset, changeset)
    |> add_breadcrumbs(contest, participant)
    |> add_breadcrumb(icon: "pencil", path: edit_path)
    |> render("edit.html")
  end

  defp add_breadcrumbs(conn, %Contest{} = contest, %Participant{} = participant) do
    conn
    |> add_contest_breadcrumb(contest)
    |> add_participants_breadcrumb(contest)
    |> add_participant_breadcrumb(contest, participant)
  end

  defp add_participant_breadcrumb(conn, %Contest{} = contest, %Participant{} = participant) do
    add_breadcrumb(conn,
      name: full_name(participant),
      path: Routes.internal_contest_participant_path(conn, :show, contest, participant)
    )
  end

  defp extract_merge_field_atoms(field_map) do
    field_map
    |> Enum.filter(fn {_, value} -> Utils.parse_bool(value) end)
    |> Enum.map(fn {key, _} -> String.to_existing_atom(key) end)
  end
end
