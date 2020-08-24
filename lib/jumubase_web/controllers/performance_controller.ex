defmodule JumubaseWeb.PerformanceController do
  use JumubaseWeb, :controller
  alias Ecto.Changeset
  alias Jumubase.Mailer
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias JumubaseWeb.Email

  # Authorize nested contest, then pass it to all actions
  def action(conn, _) do
    if action_name(conn) in [:edit, :update] do
      contest_deadline_check_action(conn, __MODULE__)
    else
      contest_openness_check_action(conn, __MODULE__)
    end
  end

  def new(conn, _params, contest) do
    conn
    |> assign(:contest, contest)
    |> render("new.html")
  end

  def create(conn, params, contest) do
    performance_params = params["performance"] || %{}

    case Showtime.create_performance(contest, performance_params) do
      {:ok, %{edit_code: edit_code} = performance} ->
        Email.registration_success(performance) |> Mailer.deliver_later()

        conn
        |> put_flash(:success, registration_success_message(edit_code))
        |> redirect(to: Routes.page_path(conn, :home))

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
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, %Changeset{} = changeset} ->
        conn
        |> prepare_for_form(contest, changeset)
        |> assign(:performance, performance)
        |> render("edit.html")

      {:error, :has_results} ->
        conn
        |> put_flash(
          :error,
          gettext("Your changes could not be saved. Please contact us if you need assistance.")
        )
        |> redirect(to: Routes.page_path(conn, :edit_registration))
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

    edit_msg =
      gettext("You can still change it later using the edit code %{edit_code}.",
        edit_code: edit_code
      )

    "#{success_msg} #{edit_msg}"
  end
end
