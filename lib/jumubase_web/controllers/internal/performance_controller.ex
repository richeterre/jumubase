defmodule JumubaseWeb.Internal.PerformanceController do
  use JumubaseWeb, :controller
  import Jumubase.Utils, only: [parse_bool: 1]
  import JumubaseWeb.PerformanceController, only: [normalize_params: 1]
  import JumubaseWeb.ErrorHelpers, only: [get_translated_errors: 1]
  alias Ecto.Changeset
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter

  plug :add_home_breadcrumb
  plug :add_breadcrumb, name: gettext("Contests"), path_fun: &Routes.internal_contest_path/2, action: :index

  # Check nested contest permissions and pass to all actions
  def action(conn, _), do: contest_user_check_action(conn, __MODULE__)

  def index(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_breadcrumbs(contest)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}, contest) do
    performance = Showtime.get_performance!(contest, id)

    conn
    |> assign(:contest, contest)
    |> assign(:performance, performance)
    |> add_breadcrumbs(contest, performance)
    |> render("show.html")
  end

  def new(conn, _params, contest) do
    changeset =
      Showtime.build_performance(contest)
      |> Showtime.change_performance

    conn
    |> prepare_for_form(contest, changeset)
    |> render("new.html")
  end

  def create(conn, params, contest) do
    performance_params = params["performance"] || %{}

    case Showtime.create_performance(contest, performance_params) do
      {:ok, performance} ->
        conn
        |> put_flash(:success, gettext("The performance was created."))
        |> redirect(to: Routes.internal_contest_performance_path(conn, :show, contest, performance))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest, changeset)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}, contest) do
    performance = Showtime.get_performance!(contest, id)

    conn
    |> prepare_for_form(contest, performance, Showtime.change_performance(performance))
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "performance" => params}, contest) do
    params = normalize_params(params)

    performance = Showtime.get_performance!(contest, id)
    case Showtime.update_performance(contest, performance, params) do
      {:ok, performance} ->
        conn
        |> put_flash(:success, gettext("The performance was updated."))
        |> redirect(to: Routes.internal_contest_performance_path(conn, :show, contest, performance))
      {:error, changeset} ->
        conn
        |> prepare_for_form(contest, performance, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}, contest) do
    Showtime.get_performance!(contest, id) |> Showtime.delete_performance!

    conn
    |> put_flash(:success, gettext("The performance was deleted."))
    |> redirect(to: Routes.internal_contest_performance_path(conn, :index, contest))
  end

  def reschedule(conn, %{"performances" => params}, contest) do
    items = Enum.map(params, fn {key, value} ->
      %{id: key, stage_id: value["stageId"], stage_time: value["stageTime"]}
    end)

    case Showtime.reschedule_performances(contest, items) do
      {:ok, stage_times} ->
        conn
        |> assign(:stage_times, stage_times)
        |> render("reschedule_success.json")
      {:error, p_id, changeset} ->
        conn
        |> assign(:performance_id, p_id)
        |> assign(:errors, changeset |> get_translated_errors)
        |> put_status(422)
        |> render("reschedule_failure.json")
    end
  end

  def jury_material(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Create jury material"), path: current_path(conn))
    |> render("jury_material.html")
  end

  def print_jury_sheets(conn, %{"performance_ids" => p_ids}, contest) do
    performances = Showtime.list_performances(contest, p_ids) |> Showtime.load_pieces

    conn
    |> assign(:performances, performances)
    |> assign(:round, contest.round)
    |> render("jury_sheets.pdf")
  end

  def print_jury_table(conn, %{"performance_ids" => p_ids}, contest) do
    performances = Showtime.list_performances(contest, p_ids)

    conn
    |> assign(:performances, performances)
    |> render("jury_table.pdf")
  end

  def edit_results(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Enter points"), path: current_path(conn))
    |> render("edit_results.html")
  end

  def update_results(conn, %{"results" => results} = params, contest) do
    %{"appearance_ids" => a_id_string, "points" => points} = results
    a_ids = a_id_string |> String.split(",")
    appearances = Showtime.list_appearances(contest, a_ids)

    list_path = case params["performance_filter"] do
      filter when is_map(filter) ->
        Routes.internal_contest_results_path(conn, :edit_results, contest, performance_filter: filter)
      _ ->
        Routes.internal_contest_results_path(conn, :edit_results, contest)
    end

    case Showtime.set_points(appearances, points) do
      :ok ->
        conn |> redirect(to: list_path)
      :error ->
        conn
        |> put_flash(:error, gettext("The points could not be saved at this time."))
        |> redirect(to: list_path)
    end
  end

  def publish_results(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Publish results"), path: current_path(conn))
    |> render("publish_results.html")
  end

  def update_results_public(conn, %{"performance_ids" => p_ids, "public" => public} = params, contest) do
    public = parse_bool(public)
    list_path = case params["performance_filter"] do
      filter when is_map(filter) ->
        Routes.internal_contest_results_path(conn, :publish_results, contest, performance_filter: filter)
      _ ->
        Routes.internal_contest_results_path(conn, :publish_results, contest)
    end

    {:ok, count} = case public do
      true -> Showtime.publish_results(contest, p_ids)
      false -> Showtime.unpublish_results(contest, p_ids)
    end

    conn
    |> put_results_flash_message(public, count)
    |> redirect(to: list_path)
  end

  # Private helpers

  defp prepare_filtered_list(conn, params, contest) do
    filter_params = params["performance_filter"] || %{}
    filter = PerformanceFilter.from_params(filter_params)
    filter_cs = PerformanceFilter.changeset(filter_params)

    conn
    |> assign(:contest, contest)
    |> assign(:filter_changeset, filter_cs)
    |> handle_filter(filter, contest)
  end

  defp handle_filter(conn, filter, contest) do
    if PerformanceFilter.active?(filter) do
      conn
      |> assign(:filter_active, true)
      |> assign(:performances, Showtime.list_performances(contest, filter))
    else
      conn
      |> assign(:filter_active, false)
      |> assign(:performances, Showtime.list_performances(contest))
    end
  end

  defp prepare_for_form(conn, %Contest{} = c, %Changeset{} = cs) do
    conn
    |> assign(:contest, c)
    |> assign(:changeset, cs)
    |> add_breadcrumbs(c)
    |> add_breadcrumb(icon: "plus", path: current_path(conn))
  end
  defp prepare_for_form(conn, %Contest{} = c, %Performance{} = p, %Changeset{} = cs) do
    conn
    |> assign(:contest, c)
    |> assign(:performance, p)
    |> assign(:changeset, cs)
    |> add_breadcrumbs(c, p)
    |> add_breadcrumb(icon: "pencil", path: current_path(conn))
  end

  defp add_breadcrumbs(conn, %Contest{} = c) do
    conn
    |> add_contest_breadcrumb(c)
    |> add_performances_breadcrumb(c)
  end

  defp add_breadcrumbs(conn, %Contest{} = c, %Performance{} = p) do
    performance_path = Routes.internal_contest_performance_path(conn, :show, c, p)

    conn
    |> add_breadcrumbs(c)
    |> add_breadcrumb(name: p.edit_code, path: performance_path)
  end

  defp put_results_flash_message(conn, true, count) do
    message = ngettext(
      "The results of this performance were published.",
      "The results of these %{count} performances were published.",
      count
    )
    conn |> put_flash(:success, message)
  end
  defp put_results_flash_message(conn, false, count) do
    message = ngettext(
      "The results of this performance were unpublished.",
      "The results of these %{count} performances were unpublished.",
      count
    )
    conn |> put_flash(:warning, message)
  end
end
