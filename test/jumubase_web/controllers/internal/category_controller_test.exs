defmodule JumubaseWeb.Internal.CategoryControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    @tag login_as: "admin"
    test "lets admins list all categories", %{conn: conn} do
      conn = attempt_index(conn)
      assert html_response(conn, 200) =~ "Categories"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to list all categories", %{conn: conn} do
        conn |> attempt_index |> assert_unauthorized_user
      end
    end

    test "redirects guests when trying to list all categories", %{conn: conn} do
      conn |> attempt_index |> assert_unauthorized_guest
    end
  end

  describe "new/2" do
    @tag login_as: "admin"
    test "lets admins fill in a new category", %{conn: conn} do
      conn = attempt_new(conn)
      assert html_response(conn, 200) =~ "New Category"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to fill in a new category", %{conn: conn} do
        conn |> attempt_new |> assert_unauthorized_user
      end
    end

    test "redirects guests when trying to fill in a new category", %{conn: conn} do
      conn |> attempt_new |> assert_unauthorized_guest
    end
  end

  @create_attrs %{name: "New name"}

  describe "create/2" do
    @tag login_as: "admin"
    test "lets admins create a new category", %{conn: conn} do
      conn = attempt_create(conn)
      assert_create_success(conn)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to create a new category", %{conn: conn} do
        conn |> attempt_create |> assert_unauthorized_user
      end
    end

    test "redirects guests when trying to create a new category", %{conn: conn} do
      conn |> attempt_create |> assert_unauthorized_guest
    end
  end

  describe "edit/2" do
    @tag login_as: "admin"
    test "lets admins edit a category", %{conn: conn} do
      conn = attempt_edit(conn)
      assert html_response(conn, 200) =~ "Edit Category"
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to edit a category", %{conn: conn} do
        conn |> attempt_edit |> assert_unauthorized_user
      end
    end

    test "redirects guests when trying to edit a category", %{conn: conn} do
      conn |> attempt_edit |> assert_unauthorized_guest
    end
  end

  @update_attrs %{name: "Edited name"}

  describe "update/2" do
    @tag login_as: "admin"
    test "lets admins update a new category", %{conn: conn} do
      conn = attempt_update(conn)
      assert_update_success(conn)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users when trying to update a new category", %{conn: conn} do
        conn |> attempt_update |> assert_unauthorized_user
      end
    end

    test "redirects guests when trying to update a new category", %{conn: conn} do
      conn |> attempt_update |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_index(conn) do
    get(conn, Routes.internal_category_path(conn, :index))
  end

  defp attempt_new(conn) do
    get(conn, Routes.internal_category_path(conn, :new))
  end

  defp attempt_create(conn) do
    valid_attrs = params_for(:category, @create_attrs)
    post(conn, Routes.internal_category_path(conn, :create), category: valid_attrs)
  end

  defp attempt_edit(conn) do
    cg = insert(:category)
    get(conn, Routes.internal_category_path(conn, :edit, cg))
  end

  defp attempt_update(conn) do
    cg = insert(:category)
    patch(conn, Routes.internal_category_path(conn, :update, cg), category: @update_attrs)
  end

  defp assert_create_success(conn) do
    redirect_path = Routes.internal_category_path(conn, :index)
    assert redirected_to(conn) == redirect_path
    conn = get(recycle(conn), redirect_path) # Follow redirection
    assert html_response(conn, 200) =~ @create_attrs[:name]
  end

  defp assert_update_success(conn) do
    redirect_path = Routes.internal_category_path(conn, :index)
    assert redirected_to(conn) == redirect_path
    conn = get(recycle(conn), redirect_path) # Follow redirection
    assert html_response(conn, 200) =~ @update_attrs[:name]
  end
end
