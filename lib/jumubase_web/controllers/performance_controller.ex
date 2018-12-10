defmodule JumubaseWeb.PerformanceController do
  use JumubaseWeb, :controller
  alias Ecto.Changeset
  alias Jumubase.Mailer
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, ContestCategory}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias JumubaseWeb.Email

  # Check deadline of nested contest and pass it to all actions
  def action(conn, _), do: contest_deadline_check_action(conn, __MODULE__)

  def new(conn, _params, contest) do
    changeset =
      build_new_performance(contest)
      |> Showtime.change_performance

    conn
    |> prepare_for_form(contest, changeset)
    |> assign_matching_kimu_contest(contest)
    |> render("new.html")
  end

  def create(conn, params, contest) do
    performance_params = params["performance"] || %{}

    case Showtime.create_performance(contest, performance_params) do
      {:ok, %{edit_code: edit_code} = performance} ->
        Email.registration_success(performance) |> Mailer.deliver_later

        conn
        |> put_flash(:success, registration_success_message(edit_code))
        |> redirect(to: page_path(conn, :home))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest, changeset)
        |> assign_matching_kimu_contest(contest)
        |> render("new.html")
    end
  end

  def edit(conn, %{"edit_code" => edit_code}, contest) do
    performance = Showtime.lookup_performance!(contest, edit_code)

    conn
    |> prepare_for_form(contest, Showtime.change_performance(performance))
    |> assign(:performance, performance)
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "edit_code" => edit_code, "performance" => params}, contest) do
    params = normalize_params(params)

    performance = Showtime.get_performance!(contest, id, edit_code)
    case Showtime.update_performance(contest, performance, params) do
      {:ok, _} ->
        conn
        |> put_flash(:success, gettext("Your changes to the registration were saved."))
        |> redirect(to: page_path(conn, :home))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest, changeset)
        |> assign(:performance, performance)
        |> render("edit.html")
    end
  end

  @doc """
  Fills in empty performance associations if missing. This prevents such changes
  from being ignored and enforces correct error handling of missing associations,
  such as when removing all appearances while editing a performance.
  """
  def normalize_params(params) do
    params
    |> Map.put_new("appearances", [])
    |> Map.put_new("pieces", [])
  end

  # Private helpers

  # Returns a performance struct for the contest's registration form.
  # Kimu contests typically have only one category, so we can pre-populate it.
  defp build_new_performance(%Contest{round: 0} = contest) do
    contest = Foundation.load_contest_categories(contest)
    case contest do
      %Contest{contest_categories: [%ContestCategory{id: cc_id}]} ->
        %Performance{
          contest_category_id: cc_id,
          appearances: [%Appearance{}],
          pieces: [%Piece{}]
        }
      _ ->
        %Performance{}
    end
  end
  defp build_new_performance(%Contest{}), do: %Performance{}

  defp prepare_for_form(conn, %Contest{} = contest, %Changeset{} = changeset) do
    conn
    |> assign(:contest, contest)
    |> assign(:changeset, changeset)
  end

  defp assign_matching_kimu_contest(conn, %Contest{} = c) do
    conn
    |> assign(:kimu_contest, Foundation.get_matching_kimu_contest(c))
  end

  defp registration_success_message(edit_code) do
    success_msg = gettext("We received your registration!")
    edit_msg = gettext("You can still change it later using the edit code %{edit_code}.", edit_code: edit_code)
    "#{success_msg} #{edit_msg}"
  end
end
