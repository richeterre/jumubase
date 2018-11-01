defmodule JumubaseWeb.Internal.CategoryControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "for an admin" do
    @describetag login_as: "admin"

    test "lists all categories", %{conn: conn} do
      conn = get(conn, internal_category_path(conn, :index))
      assert html_response(conn, 200) =~ "Categories"
    end

    test "renders new category form", %{conn: conn} do
      conn = get(conn, internal_category_path(conn, :new))
      assert html_response(conn, 200) =~ "New Category"
    end

    test "redirects to category list after creating a category", %{conn: conn} do
      valid_attrs = params_for(:category, name: "XYZ")
      conn = post(conn, internal_category_path(conn, :create), category: valid_attrs)
      redirect_path = internal_category_path(conn, :index)

      assert redirected_to(conn) == redirect_path
      conn = get(recycle(conn), redirect_path) # Follow redirection
      assert html_response(conn, 200) =~ "XYZ"
    end

    test "renders errors when category creation fails with invalid data", %{conn: conn} do
      conn = post(conn, internal_category_path(conn, :create), category: %{})
      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "for a non-admin" do
    for role <- roles_except("admin") do
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
      get(conn, internal_category_path(conn, :index)),
      get(conn, internal_category_path(conn, :new)),
      post(conn, internal_category_path(conn, :create), %{category: %{}}),
    ], fn conn ->
      assertion_fun.(conn)
    end)
  end
end
