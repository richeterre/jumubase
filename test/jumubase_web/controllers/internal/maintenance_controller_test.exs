defmodule JumubaseWeb.Internal.MaintenanceControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    @tag login_as: "admin"
    test "lets admins view data maintenance info", %{conn: conn} do
      conn |> attempt_index |> assert_index_success
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to view data maintenance info", %{conn: conn} do
        conn |> attempt_index |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to view data maintenance info", %{conn: conn} do
      conn |> attempt_index |> assert_unauthorized_guest
    end
  end

  describe "delete_orphaned_participants/2" do
    @tag login_as: "admin"
    test "lets admins delete orphaned participants", %{conn: conn} do
      conn |> attempt_delete_orphaned_participants |> assert_delete_orphaned_participants_success
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to delete orphaned participants", %{conn: conn} do
        conn |> attempt_delete_orphaned_participants |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to delete orphaned participants", %{conn: conn} do
      conn |> attempt_delete_orphaned_participants |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_index(conn) do
    get(conn, Routes.internal_maintenance_path(conn, :index))
  end

  defp assert_index_success(conn) do
    assert html_response(conn, 200) =~ "Data maintenance"
  end

  defp attempt_delete_orphaned_participants(conn) do
    insert_list(2, :participant)
    delete(conn, Routes.internal_maintenance_path(conn, :delete_orphaned_participants))
  end

  defp assert_delete_orphaned_participants_success(conn) do
    assert_flash_redirect(
      conn,
      Routes.internal_maintenance_path(conn, :index),
      "2 orphaned participants were deleted."
    )
  end

  defp assert_flash_redirect(conn, redirect_path, message) do
    assert redirected_to(conn) == redirect_path
    # Follow redirection
    conn = get(recycle(conn), redirect_path)
    assert html_response(conn, 200) =~ message
  end
end
