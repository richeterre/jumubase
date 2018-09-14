defmodule JumubaseWeb.Internal.PageController do
  use JumubaseWeb, :controller
  import JumubaseWeb.Authorize

  plug :user_check

  def home(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    render(conn, "home.html", name: user.first_name)
  end
end
