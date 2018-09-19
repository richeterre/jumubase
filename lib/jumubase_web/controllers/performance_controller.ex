defmodule JumubaseWeb.PerformanceController do
  use JumubaseWeb, :controller
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance}

  def new(conn, %{"contest_id" => contest_id}) do
    changeset =
      %Performance{appearances: [%Appearance{}]}
      |> Showtime.change_performance()

    conn
    |> prepare_for_form(contest_id, changeset)
    |> render("new.html")
  end

  def create(conn, %{"contest_id" => contest_id, "performance" => params}) do
    case Showtime.create_performance(params) do
      {:ok, _} ->
        conn
        |> put_flash(:success, gettext("Success!"))
        |> redirect(to: page_path(conn, :home))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest_id, changeset)
        |> render("new.html")
    end
  end

  defp prepare_for_form(conn, contest_id, %Changeset{} = changeset) do
    contest = contest_id
    |> Foundation.get_contest!
    |> Foundation.load_contest_categories

    contest_category_options = contest.contest_categories
    |> Enum.map(&{&1.category.name, &1.id})

    conn
    |> assign(:contest, contest)
    |> assign(:contest_category_options, contest_category_options)
    |> assign(:changeset, changeset)
  end
end
