defmodule JumubaseWeb.ErrorViewTest do
  use JumubaseWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(JumubaseWeb.Router, [:browser])
      |> get("/")

    {:ok, conn: conn}
  end

  test "renders 404.html", %{conn: conn} do
    assert render_to_string(JumubaseWeb.ErrorView, "404.html", conn: conn) =~
      "The page was not found."
  end

  test "render 500.html", %{conn: conn} do
    assert render_to_string(JumubaseWeb.ErrorView, "500.html", conn: conn) =~
      "Something went wrong"
  end

  test "render any other", %{conn: conn} do
    assert render_to_string(JumubaseWeb.ErrorView, "505.html", conn: conn) =~
      "Something went wrong"
  end
end
