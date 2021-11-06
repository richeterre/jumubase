defmodule JumubaseWeb.Internal.ContestLive.IndexTest do
  use JumubaseWeb.ConnCase
  import Phoenix.LiveViewTest
  import JumubaseWeb.Internal.ContestView, only: [name: 1]

  setup config do
    login_if_needed(config)
  end

  @tag login_as: "admin"
  test "mounts correctly", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/internal/contests")
    assert html =~ "<h2>Contests</h2>"
  end

  for role <- all_roles() do
    @tag login_as: role
    test "lists all authorized contests to #{role} users", %{conn: conn, user: u} do
      c1 = insert_authorized_contest(u)
      c2 = insert_authorized_contest(u)

      {:ok, _view, html} = live(conn, "/internal/contests")

      assert html =~ name(c1)
      assert html =~ name(c2)
    end
  end

  for role <- ["local-organizer", "global-organizer"] do
    @tag login_as: role
    test "only lists authorized contests to #{role} users", %{conn: conn, user: u} do
      c1 = insert_authorized_contest(u)
      c2 = insert_unauthorized_contest(u)

      {:ok, _view, html} = live(conn, "/internal/contests")

      assert html =~ name(c1)
      refute html =~ name(c2)
    end
  end

  test "redirects guests trying to list all contests", %{conn: conn} do
    conn = get(conn, "/internal/contests")
    assert_unauthorized_guest(conn)
  end
end
