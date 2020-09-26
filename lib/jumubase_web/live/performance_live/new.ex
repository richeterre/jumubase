defmodule JumubaseWeb.PerformanceLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Mailer
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias JumubaseWeb.Email
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.PerformanceView.render("live_form.html", assigns)
  end

  def mount(_params, assigns, socket) do
    {:ok, prepare(socket, assigns, include_kimu_contest: true)}
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

  def handle_event("submit", %{"performance" => attrs}, socket) do
    contest = socket.assigns.contest

    case Showtime.create_performance(contest, attrs) do
      {:ok, %{edit_code: edit_code} = performance} ->
        Email.registration_success(performance) |> Mailer.deliver_later()

        {:noreply,
         socket
         |> put_flash(:success, registration_success_message(edit_code))
         |> redirect(to: Routes.page_path(socket, :home))}

      {:error, changeset} ->
        {:noreply, handle_failed_submit(socket, changeset)}
    end
  end

  def prepare(socket, %{"contest_id" => c_id, "submit_title" => submit_title}, opts \\ []) do
    contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

    kimu_contest =
      if opts[:include_kimu_contest],
        do: Foundation.get_matching_kimu_contest(contest),
        else: nil

    changeset =
      %Performance{}
      |> Showtime.change_performance()
      |> append_appearance()
      |> append_piece()

    assign(socket,
      changeset: changeset,
      contest: contest,
      kimu_contest: kimu_contest,
      expanded_appearance_index: nil,
      expanded_piece_index: nil,
      submit_title: submit_title
    )
  end

  def change(socket, attrs) do
    contest = socket.assigns.contest

    changeset =
      Performance.changeset(%Performance{}, attrs, contest.round)
      |> Map.put(:action, :insert)

    assign(socket, changeset: changeset)
  end

  def add_appearance(socket) do
    changeset = socket.assigns.changeset
    index = get_appearance_count(changeset)

    assign(socket,
      changeset: append_appearance(changeset),
      expanded_appearance_index: socket.assigns.expanded_appearance_index || index
    )
  end

  def remove_appearance(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :appearances, index)
    assign(socket, changeset: changeset)
  end

  def add_piece(socket) do
    changeset = socket.assigns.changeset
    index = get_piece_count(changeset)

    assign(socket,
      changeset: append_piece(changeset),
      expanded_piece_index: socket.assigns.expanded_piece_index || index
    )
  end

  def remove_piece(socket, index) do
    changeset = remove_item(socket.assigns.changeset, :pieces, index)
    assign(socket, changeset: changeset)
  end

  # Private helpers

  defp get_appearance_count(cs), do: get_existing_items(cs, :appearances) |> length()
  defp append_appearance(cs), do: append_item(cs, :appearances, %Appearance{})

  defp get_piece_count(cs), do: get_existing_items(cs, :pieces) |> length()
  defp append_piece(cs), do: append_item(cs, :pieces, %Piece{})

  defp get_existing_items(cs, field) do
    Map.get(cs.changes, field, [])
  end

  defp append_item(cs, field, item) do
    items = get_existing_items(cs, field) ++ [item]
    Changeset.put_assoc(cs, field, items)
  end

  defp remove_item(cs, field, index) do
    items = get_existing_items(cs, field) |> List.delete_at(index)
    Changeset.put_assoc(cs, field, items)
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
