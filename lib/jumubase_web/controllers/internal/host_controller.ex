defmodule JumubaseWeb.Internal.HostController do
  use JumubaseWeb, :controller
  alias Jumubase.Repo
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Host

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Hosts"), path_fun: &internal_host_path/2, action: :index

  plug :role_check, roles: ["admin"]

  def index(conn, _params) do
    render(conn, "index.html", hosts: Foundation.list_hosts())
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Host.changeset(%Host{}, %{}))
    |> add_breadcrumb(icon: "plus", path: internal_host_path(conn, :new))
    |> render("new.html")
  end

  def create(conn, %{"host" => host_params}) do
    changeset = Host.changeset(%Host{}, host_params)

    case Repo.insert(changeset) do
      {:ok, host} ->
        conn
        |> put_flash(:success,
          gettext("The host \"%{name}\" was created.", name: host.name))
        |> redirect(to: internal_host_path(conn, :index))
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
