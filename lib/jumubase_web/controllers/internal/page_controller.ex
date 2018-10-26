defmodule JumubaseWeb.Internal.PageController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Authorize

  plug :add_home_breadcrumb

  plug :user_check

  def home(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    render(conn, "home.html", current_user: user, contests: [])
  end
end
