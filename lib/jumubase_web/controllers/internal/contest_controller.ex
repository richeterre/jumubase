defmodule JumubaseWeb.Internal.ContestController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.ContestView, only: [name: 1, name_with_flag: 1, round_options: 0]
  import JumubaseWeb.Internal.HostView, only: [grouping_options: 0]
  alias Ecto.Changeset
  alias Jumubase.Utils
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias JumubaseWeb.Internal.ContestLive

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Contests"),
    path_fun: &Routes.internal_live_path/2,
    action: ContestLive.Index

  plug :admin_check when action in [:new, :edit, :update, :delete]
  plug :non_observer_check when action in [:prepare, :update_timetables_public]
  plug :contest_user_check when action in [:show, :prepare, :update_timetables_public]

  def show(conn, %{"id" => id}) do
    contest =
      Foundation.get_contest!(id)
      |> Foundation.load_contest_categories()
      |> Foundation.load_used_stages()

    performances = contest |> Showtime.list_performances()
    result_completions = performances |> Showtime.result_completions()

    conn
    |> assign(:contest, contest)
    |> assign(:performances, performances)
    |> assign(:result_completions, result_completions)
    |> add_contest_breadcrumb(contest)
    |> render("show.html")
  end

  def new(conn, _params) do
    conn
    |> add_breadcrumb(icon: "plus", path: Routes.internal_contest_path(conn, :new))
    |> render("new.html")
  end

  def edit(conn, %{"id" => id}) do
    contest = Foundation.get_contest!(id)
    changeset = Foundation.change_contest(contest)
    render_edit_form(conn, contest, changeset)
  end

  def update(conn, %{"id" => id, "contest" => params}) do
    contest = Foundation.get_contest!(id)

    case Foundation.update_contest(contest, params) do
      {:ok, contest} ->
        conn
        |> put_flash(:info, gettext("The contest %{name} was updated.", name: name(contest)))
        |> redirect(to: Routes.internal_live_path(conn, ContestLive.Index))

      {:error, %Changeset{} = changeset} ->
        render_edit_form(conn, contest, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contest = Foundation.get_contest!(id)
    Foundation.delete_contest!(contest)

    conn
    |> put_flash(:success, gettext("The contest %{name} was deleted.", name: name(contest)))
    |> redirect(to: Routes.internal_live_path(conn, ContestLive.Index))
  end

  def prepare(conn, %{"contest_id" => id}) do
    contest = Foundation.get_contest!(id)

    conn
    |> assign(:contest, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(
      name: gettext("Open Registration"),
      path: Routes.internal_contest_prepare_path(conn, :prepare, contest)
    )
    |> render("prepare.html")
  end

  def update_timetables_public(conn, %{"contest_id" => id, "public" => public}) do
    contest = Foundation.get_contest!(id)

    conn =
      case Utils.parse_bool(public) do
        true -> publish_timetables(conn, contest)
        false -> unpublish_timetables(conn, contest)
      end

    redirect(conn, to: Routes.internal_contest_stage_path(conn, :index, contest))
  end

  # Private helpers

  defp render_edit_form(conn, %Contest{} = contest, %Changeset{} = changeset) do
    contest_path = Routes.internal_contest_path(conn, :show, contest)
    edit_path = Routes.internal_contest_path(conn, :edit, contest)

    conn
    |> add_breadcrumb(name: name_with_flag(contest), path: contest_path)
    |> add_breadcrumb(icon: "pencil", path: edit_path)
    |> assign(:contest, contest)
    |> prepare_for_form(changeset)
    |> render("edit.html")
  end

  defp prepare_for_form(conn, %Changeset{} = changeset) do
    host_options = Foundation.list_hosts() |> Enum.map(&{&1.name, &1.id})

    conn
    |> assign(:changeset, changeset)
    |> assign(:host_options, host_options)
    |> assign(:round_options, round_options())
    |> assign(:grouping_options, grouping_options())
  end

  defp publish_timetables(conn, contest) do
    case Foundation.publish_contest_timetables(contest) do
      {:ok, _} -> conn
      {:error, _} -> put_flash(conn, :error, gettext("The timetables could not be published."))
    end
  end

  defp unpublish_timetables(conn, contest) do
    case Foundation.unpublish_contest_timetables(contest) do
      {:ok, _} -> conn
      {:error, _} -> put_flash(conn, :error, gettext("The timetables could not be unpublished."))
    end
  end
end
