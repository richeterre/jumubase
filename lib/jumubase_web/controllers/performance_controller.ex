defmodule JumubaseWeb.PerformanceController do
  use JumubaseWeb, :controller
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

  # Pass contest from nested route to all actions
  def action(conn, _), do: get_contest!(conn, __MODULE__)

  def new(conn, _params, contest) do
    changeset =
      %Performance{
        appearances: [%Appearance{participant: %Participant{}}],
        pieces: [%Piece{}]
      }
      |> Showtime.change_performance()

    conn
    |> prepare_for_form(contest, changeset)
    |> render("new.html")
  end

  def create(conn, %{"performance" => params}, contest) do
    case Showtime.create_performance(contest, params) do
      {:ok, _} ->
        conn
        |> put_flash(:success, gettext("Success!"))
        |> redirect(to: page_path(conn, :home))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest, changeset)
        |> render("new.html")
    end
  end

  defp prepare_for_form(conn, %Contest{} = contest, %Changeset{} = changeset) do
    contest = Foundation.load_contest_categories(contest)

    contest_category_options = contest.contest_categories
    |> Enum.map(&{&1.category.name, &1.id})

    conn
    |> assign(:contest, contest)
    |> assign(:contest_category_options, contest_category_options)
    |> assign(:changeset, changeset)
  end
end
