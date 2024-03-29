defmodule JumubaseWeb.PerformanceLive.Edit do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.PerformanceView.render("live_form.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns)}
  end

  def handle_event("change", %{"performance" => attrs}, socket) do
    {:noreply, change(socket, attrs)}
  end

  def handle_event("add-appearance", _, socket) do
    {:noreply, add_appearance(socket)}
  end

  def handle_event("remove-appearance", %{"index" => index}, socket) do
    {:noreply, remove_appearance(socket, parse_id(index))}
  end

  def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
    {:noreply, toggle_appearance_panel(socket, parse_id(index))}
  end

  def handle_event("add-piece", _, socket) do
    {:noreply, add_piece(socket)}
  end

  def handle_event("remove-piece", %{"index" => index}, socket) do
    {:noreply, remove_piece(socket, parse_id(index))}
  end

  def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
    {:noreply, toggle_piece_panel(socket, parse_id(index))}
  end

  def handle_event("submit", %{"performance" => params}, socket) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    params = normalize_params(params)

    case Showtime.update_performance(contest, performance, params) do
      {:ok, %Performance{}} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Your changes to the registration were saved."))
         |> redirect(to: Routes.page_path(socket, :home))}

      {:error, %Changeset{} = changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}

      {:error, :has_results} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           gettext("Your changes could not be saved. Please contact us if you need assistance.")
         )
         |> redirect(to: Routes.page_path(socket, :edit_registration))}
    end
  end

  def prepare(
        socket,
        %{"contest_id" => c_id, "performance_id" => p_id, "submit_title" => submit_title}
      ) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()
    performance = Showtime.get_performance!(contest, p_id)

    changeset = Showtime.change_performance(performance)

    assign(socket,
      changeset: changeset,
      contest: contest,
      performance: performance,
      predecessor_host_options: predecessor_host_options(contest),
      expanded_appearance_index: nil,
      expanded_piece_index: nil,
      submit_title: submit_title,
      has_concept_document_field: needs_concept_document_field?(changeset, contest)
    )
  end

  def change(socket, attrs) do
    contest = socket.assigns.contest
    performance = socket.assigns.performance

    changeset =
      Performance.changeset(performance, attrs, contest.round)
      |> Showtime.handle_category_specific_fields(contest, attrs)
      |> Map.put(:action, :update)

    assign(socket,
      changeset: changeset,
      has_concept_document_field: needs_concept_document_field?(changeset, contest)
    )
  end

  def add_appearance(socket) do
    changeset = socket.assigns.changeset
    assign(socket, changeset: add_item(changeset, :appearances, %Appearance{}))
  end

  def remove_appearance(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :appearances, index)
    assign(socket, changeset: changeset)
  end

  def add_piece(socket) do
    changeset = socket.assigns.changeset
    assign(socket, changeset: add_item(changeset, :pieces, %Piece{}))
  end

  def remove_piece(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :pieces, index)
    assign(socket, changeset: changeset)
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

  defp add_item(changeset, field_name, item) do
    existing = get_assoc(changeset, field_name)
    Changeset.put_assoc(changeset, field_name, existing ++ [item])
  end

  defp remove_item(changeset, field_name, index) do
    remaining =
      changeset
      |> get_assoc(field_name)
      |> List.delete_at(index)

    Changeset.put_assoc(changeset, field_name, remaining)
  end

  defp get_assoc(changeset, field_name) do
    # This is used as a fallback if the changeset has no changes yet (e.g. right
    # after loading the edit form). Using `get_field` instead of `get_change` won't
    # work here, because it drops the user's "invalid" form edits that we want to keep.
    assoc_from_data = Map.get(changeset.data, field_name, [])

    changeset
    |> Changeset.get_change(field_name, assoc_from_data)
    |> exclude_obsolete()
  end

  defp exclude_obsolete(records_or_changesets) do
    records_or_changesets
    |> Enum.filter(fn
      %Changeset{action: action} -> action in [:insert, :update]
      _ -> true
    end)
  end
end
