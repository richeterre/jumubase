defmodule JumubaseWeb.PageController do
  use JumubaseWeb, :controller

  def home(conn, _params) do
    render(conn, "home.html")
  end
end
