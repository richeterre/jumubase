defmodule JumubaseWeb.Internal.CategoryController do
  use JumubaseWeb, :controller
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Category

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Categories"), path_fun: &internal_category_path/2, action: :index

  plug :admin_check

  def index(conn, _params) do
    render(conn, "index.html", categories: Foundation.list_categories())
  end

  def new(conn, _params) do
    conn
    |> assign(:changeset, Category.changeset(%Category{}, %{}))
    |> add_breadcrumb(icon: "plus", path: internal_category_path(conn, :new))
    |> render("new.html")
  end

  def create(conn, %{"category" => params}) do
    case Foundation.create_category(params) do
      {:ok, category} ->
        conn
        |> put_flash(:success,
          gettext("The category \"%{name}\" was created.", name: category.name))
        |> redirect(to: internal_category_path(conn, :index))
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
