defmodule JumubaseWeb.Internal.UserController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Internal.UserView, only: [full_name: 1]
  alias Ecto.Changeset
  alias Jumubase.Accounts
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation
  alias JumubaseWeb.UserAuth

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Users"),
    path_fun: &Routes.internal_user_path/2,
    action: :index

  plug :admin_check

  def index(conn, _params) do
    users = Accounts.list_users() |> Accounts.load_hosts()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{hosts: []})
    render_create_form(conn, changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("The user %{name} was created.", name: full_name(user)))
        |> redirect(to: Routes.internal_user_path(conn, :index))

      {:error, %Changeset{} = changeset} ->
        render_create_form(conn, changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id) |> Accounts.load_hosts()
    changeset = Accounts.change_user(user)
    render_edit_form(conn, user, changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id) |> Accounts.load_hosts()

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("The user %{name} was updated.", name: full_name(user)))
        |> redirect(to: Routes.internal_user_path(conn, :index))

      {:error, %Changeset{} = changeset} ->
        render_edit_form(conn, user, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, gettext("The user %{name} was deleted.", name: full_name(user)))
    |> redirect(to: Routes.internal_user_path(conn, :index))
  end

  def impersonate(conn, %{"user_id" => id}) do
    user = Accounts.get_user!(id)
    UserAuth.log_in_user(conn, user)
  end

  # Private helpers

  defp render_create_form(conn, %Changeset{} = changeset) do
    conn
    |> add_breadcrumb(icon: "plus", path: Routes.internal_user_path(conn, :new))
    |> prepare_for_form(changeset)
    |> render("new.html")
  end

  defp render_edit_form(conn, %User{} = user, %Changeset{} = changeset) do
    edit_path = Routes.internal_user_path(conn, :edit, user)

    conn
    |> add_breadcrumb(name: full_name(user), path: edit_path)
    |> add_breadcrumb(icon: "pencil", path: edit_path)
    |> prepare_for_form(changeset)
    |> render("edit.html", user: user)
  end

  defp prepare_for_form(conn, %Changeset{} = changeset) do
    host_options = Foundation.list_hosts() |> Enum.map(&{&1.name, &1.id})

    conn
    |> assign(:changeset, changeset)
    |> assign(:host_options, host_options)
  end
end
