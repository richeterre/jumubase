defmodule JumubaseWeb.Internal.CategoryController do
  use JumubaseWeb, :controller
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Category

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Categories"), path_fun: &Routes.internal_category_path/2, action: :index

  plug :admin_check

  def index(conn, _params) do
    render(conn, "index.html", categories: Foundation.list_categories())
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Category.changeset(%Category{}, %{}))
    |> add_breadcrumb(icon: "plus", path: Routes.internal_category_path(conn, :new))
    |> render("new.html")
  end

  def create(conn, %{"category" => params}) do
    case Foundation.create_category(params) do
      {:ok, category} ->
        conn
        |> put_flash(:success,
          gettext("The category \"%{name}\" was created.", name: category.name))
        |> redirect(to: Routes.internal_category_path(conn, :index))
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    category = Foundation.get_category!(id)
    changeset = Foundation.change_category(category)
    render_edit_form(conn, category, changeset)
  end

  def update(conn, %{"id" => id, "category" => params}) do
    category = Foundation.get_category!(id)

    case Foundation.update_category(category, params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, gettext("The category %{name} was updated.", name: category.name))
        |> redirect(to: Routes.internal_category_path(conn, :index))
      {:error, %Changeset{} = changeset} ->
        render_edit_form(conn, category, changeset)
    end
  end

  # Private helpers

  defp render_edit_form(conn, %Category{} = category, %Changeset{} = changeset) do
    edit_path = Routes.internal_category_path(conn, :edit, category)
    conn
    |> assign(:changeset, changeset)
    |> add_breadcrumb(name: category.name, path: edit_path)
    |> add_breadcrumb(icon: "pencil", path: edit_path)
    |> render("edit.html", category: category)
  end
end
