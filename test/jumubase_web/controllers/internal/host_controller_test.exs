defmodule JumubaseWeb.Internal.HostControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "for an admin" do
    @describetag login_as: "admin"

    test "lists all hosts", %{conn: conn} do
      conn = get(conn, internal_host_path(conn, :index))
      assert html_response(conn, 200) =~ "Hosts"
    end

    test "renders new host form", %{conn: conn} do
      conn = get(conn, internal_host_path(conn, :new))
      assert html_response(conn, 200) =~ "New Host"
    end

    test "redirects to host list after creating a host", %{conn: conn} do
      valid_attrs = params_for(:host)
      conn = post(conn, internal_host_path(conn, :create), host: valid_attrs)
      assert redirected_to(conn) == internal_host_path(conn, :index)
    end

    test "renders errors when host creation fails with invalid data", %{conn: conn} do
      conn = post(conn, internal_host_path(conn, :create), host: %{})
      assert html_response(conn, 200) =~ "New Host"
    end
  end

  describe "for a non-admin" do
    for role <- non_admin_roles() do
      @tag login_as: role
      test "(#{role}) redirects when trying to perform any action", %{conn: conn} do
        verify_all_routes(conn, &assert_unauthorized_user/1)
      end
    end
  end

  describe "for a guest" do
    test "redirects when trying to perform any action", %{conn: conn} do
      verify_all_routes(conn, &assert_unauthorized_guest/1)
    end
  end

  # Private helpers

  defp verify_all_routes(conn, assertion_fun) do
    Enum.each([
      get(conn, internal_host_path(conn, :index)),
      get(conn, internal_host_path(conn, :new)),
      post(conn, internal_host_path(conn, :create), %{host: %{}}),
    ], fn conn ->
      assertion_fun.(conn)
    end)
  end
end
