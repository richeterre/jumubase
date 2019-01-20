defmodule JumubaseWeb.Internal.ContestController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.ContestView, only: [name: 1, name_with_flag: 1, round_options: 0]
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias JumubaseWeb.Internal.Permit

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &Routes.internal_contest_path/2, action: :index

  plug :user_check when action in [:index]
  plug :contest_user_check when action in [:show]
  plug :admin_check when action in [:edit, :update]

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    contests =
      Contest
      |> Permit.scope_contests(user)
      |> Foundation.list_contests

    conn
    |> assign(:contests, contests)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    contest =
      Foundation.get_contest!(id)
      |> Foundation.load_contest_categories
      |> Foundation.load_used_stages

    performances = contest |> Showtime.list_performances
    conn
    |> assign(:contest, contest)
    |> assign(:performances, performances)
    |> add_contest_breadcrumb(contest)
    |> render("show.html")
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
        |> redirect(to: Routes.internal_contest_path(conn, :index))

      {:error, %Changeset{} = changeset} ->
        render_edit_form(conn, contest, changeset)
    end
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
    host_options = Foundation.list_hosts |> Enum.map(&({&1.name, &1.id}))
    conn
    |> assign(:changeset, changeset)
    |> assign(:host_options, host_options)
    |> assign(:round_options, round_options())
  end
end
