defmodule JumubaseWeb.Internal.UserController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Authorize
  import JumubaseWeb.Internal.UserView, only: [full_name: 1]

  alias Jumubase.Accounts
  alias Jumubase.Accounts.User

  plug :role_check, roles: ["admin"]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("The user %{name} was created.", name: full_name(user)))
        |> redirect(to: internal_user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("The user %{name} was updated.", name: full_name(user)))
        |> redirect(to: internal_user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, gettext("The user %{name} was deleted.", name: full_name(user)))
    |> redirect(to: internal_user_path(conn, :index))
  end
end
