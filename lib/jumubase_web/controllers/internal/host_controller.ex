defmodule JumubaseWeb.Internal.HostController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Host

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Hosts"),
    path_fun: &Routes.internal_host_path/2,
    action: :index

  plug :admin_check

  def index(conn, _params) do
    render(conn, "index.html", hosts: Foundation.list_hosts())
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Host.changeset(%Host{}, %{}))
    |> add_breadcrumb(icon: "plus", path: Routes.internal_host_path(conn, :new))
    |> render("new.html")
  end

  def create(conn, %{"host" => params}) do
    case Foundation.create_host(params) do
      {:ok, host} ->
        conn
        |> put_flash(
          :success,
          gettext("The host \"%{name}\" was created.", name: host.name)
        )
        |> redirect(to: Routes.internal_host_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
