defmodule JumubaseWeb.Internal.PerformanceController do
  use JumubaseWeb, :controller
  import Jumubase.Utils, only: [parse_bool: 1, parse_ids: 1]
  import JumubaseWeb.ErrorHelpers, only: [get_translated_errors: 1]
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.PerformanceFilter
  alias JumubaseWeb.Internal.ContestLive
  alias JumubaseWeb.Internal.PerformanceView
  alias JumubaseWeb.XMLEncoder

  plug :add_home_breadcrumb

  plug :add_breadcrumb,
    name: gettext("Contests"),
    path_fun: &Routes.internal_live_path/2,
    action: ContestLive.Index

  plug :non_observer_check
       when action in [:new, :edit, :delete, :reschedule, :update_results, :update_results_public]

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
    conn
    |> prepare_for_form(contest)
    |> render("new.html")
  end

  def edit(conn, %{"id" => id}, contest) do
    performance = Showtime.get_performance!(contest, id)

    if Performance.has_results?(performance) do
      handle_has_results_error(conn, contest)
    else
      conn
      |> prepare_for_form(contest, performance)
      |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}, contest) do
    Showtime.get_performance!(contest, id) |> Showtime.delete_performance!()

    conn
    |> put_flash(:success, gettext("The performance was deleted."))
    |> redirect(to: Routes.internal_contest_performance_path(conn, :index, contest))
  end

  def reschedule(conn, %{"performances" => params}, contest) do
    items =
      Enum.map(params, fn {key, value} ->
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
    performances =
      Showtime.list_performances(contest, p_ids)
      |> Showtime.load_pieces()
      |> Showtime.load_predecessor_hosts()

    content =
      Phoenix.View.render_to_string(
        PerformanceView,
        "print_jury_sheets.html",
        %{performances: performances, round: contest.round}
      )

    send_pdf_download(conn, size: :a4, content: content)
  end

  def print_jury_table(conn, %{"performance_ids" => p_ids}, contest) do
    performances = Showtime.list_performances(contest, p_ids)

    content =
      Phoenix.View.render_to_string(
        PerformanceView,
        "print_jury_table.html",
        %{performances: performances}
      )

    send_pdf_download(conn,
      size: :a4,
      landscape: true,
      header_height: "10mm",
      footer_height: "10mm",
      content: content
    )
  end

  def edit_results(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Enter points"), path: current_path(conn))
    |> add_public_results_warning
    |> render("edit_results.html")
  end

  def update_results(conn, %{"results" => results} = params, contest) do
    %{"appearance_ids" => a_id_string, "points" => points} = results
    a_ids = parse_ids(a_id_string)

    appearances = Showtime.list_appearances(contest, a_ids)

    list_path =
      case params["performance_filter"] do
        filter when is_map(filter) ->
          Routes.internal_contest_results_path(conn, :edit_results, contest,
            performance_filter: filter
          )

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

  def update_results_public(
        conn,
        %{"performance_ids" => p_ids, "public" => public} = params,
        contest
      ) do
    public = parse_bool(public)

    list_path =
      case params["performance_filter"] do
        filter when is_map(filter) ->
          Routes.internal_contest_results_path(conn, :publish_results, contest,
            performance_filter: filter
          )

        _ ->
          Routes.internal_contest_results_path(conn, :publish_results, contest)
      end

    {:ok, count} =
      case public do
        true -> Showtime.publish_results(contest, p_ids)
        false -> Showtime.unpublish_results(contest, p_ids)
      end

    conn
    |> put_results_flash_message(public, count)
    |> redirect(to: list_path)
  end

  def certificates(conn, params, contest) do
    conn
    |> prepare_filtered_list(params, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Create certificates"), path: current_path(conn))
    |> render("certificates.html")
  end

  def print_certificates(conn, %{"performance_ids" => p_ids}, contest) do
    performances = Showtime.list_performances(contest, p_ids)

    content =
      Phoenix.View.render_to_string(
        PerformanceView,
        "print_certificates.html",
        %{contest: contest, performances: performances}
      )

    send_pdf_download(conn, size: :a4, content: content)
  end

  def advancing(conn, _params, contest) do
    conn
    |> assign(:contest, contest)
    |> add_contest_breadcrumb(contest)
    |> add_breadcrumb(name: gettext("Advancing performances"), path: current_path(conn))
    |> render("advancing.html")
  end

  def advancing_xml(conn, _params, contest) do
    performances = contest |> Showtime.advancing_performances() |> Showtime.load_successors()

    send_download(conn, {:binary, XMLEncoder.encode(performances)},
      content_type: "application/xml",
      filename: "Weiterleitungen.xml"
    )
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
    conn
    |> assign(:filter_active, PerformanceFilter.active?(filter))
    |> assign(:performances, load_performances(contest, filter))
  end

  defp load_performances(%Contest{round: 2} = c, filter) do
    # Since performances have predecessors here, preload them
    c |> Showtime.list_performances(filter) |> Showtime.load_predecessor_hosts()
  end

  defp load_performances(%Contest{} = c, filter) do
    Showtime.list_performances(c, filter)
  end

  defp prepare_for_form(conn, %Contest{} = c) do
    conn
    |> assign(:contest, c)
    |> add_breadcrumbs(c)
    |> add_breadcrumb(icon: "plus", path: current_path(conn))
  end

  defp prepare_for_form(conn, %Contest{} = c, %Performance{} = p) do
    conn
    |> assign(:contest, c)
    |> assign(:performance, p)
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
    message =
      ngettext(
        "The results of this performance were published.",
        "The results of these %{count} performances were published.",
        count
      )

    conn |> put_flash(:success, message)
  end

  defp put_results_flash_message(conn, false, count) do
    message =
      ngettext(
        "The results of this performance were unpublished.",
        "The results of these %{count} performances were unpublished.",
        count
      )

    conn |> put_flash(:warning, message)
  end

  defp add_public_results_warning(conn) do
    if performances = conn.assigns[:performances] do
      add_public_results_warning(conn, performances)
    else
      conn
    end
  end

  defp add_public_results_warning(conn, performances) do
    if Enum.any?(performances, & &1.results_public) do
      put_flash(
        conn,
        :warning,
        gettext(
          "The results of some performances below have already been published. Your changes will be visible to others instantly."
        )
      )
    else
      conn
    end
  end

  defp handle_has_results_error(conn, contest) do
    conn
    |> put_flash(
      :error,
      gettext("This performance already has results. To edit it, please clear them first.")
    )
    |> redirect(to: Routes.internal_contest_performance_path(conn, :index, contest))
  end

  defp send_pdf_download(conn, opts) do
    {:ok, conn} =
      opts
      |> ChromicPDF.Template.source_and_options()
      |> ChromicPDF.print_to_pdf(
        output: fn path ->
          send_download(conn, {:file, path}, disposition: :inline)
        end
      )

    conn
  end
end
