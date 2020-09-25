defmodule JumubaseWeb.PerformanceLive do
  import JumubaseWeb.PerformanceLive.Helpers
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  def new do
    quote do
      def render(assigns) do
        JumubaseWeb.PerformanceView.render("live_form.html", assigns)
      end

      def mount(_params, %{"contest_id" => c_id, "submit_title" => submit_title}, socket) do
        contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()

        changeset =
          %Performance{}
          |> Showtime.change_performance()
          |> append_appearance()
          |> append_piece()

        {:ok,
         assign(socket,
           changeset: changeset,
           contest: contest,
           expanded_appearance_index: nil,
           expanded_piece_index: nil,
           submit_title: submit_title
         )}
      end

      def handle_event("change", %{"performance" => attrs}, socket) do
        contest = socket.assigns.contest

        changeset =
          Performance.changeset(%Performance{}, attrs, contest.round)
          |> Map.put(:action, :insert)

        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("add-appearance", _, socket) do
        changeset = socket.assigns.changeset
        index = get_appearance_count(changeset)

        {:noreply,
         assign(socket,
           changeset: append_appearance(changeset),
           expanded_appearance_index: socket.assigns.expanded_appearance_index || index
         )}
      end

      def handle_event("remove-appearance", %{"index" => index}, socket) do
        changeset = remove_appearance(socket.assigns.changeset, parse_id(index))
        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
        {:noreply, toggle_appearance_panel(socket, parse_id(index))}
      end

      def handle_event("add-piece", _, socket) do
        changeset = socket.assigns.changeset
        index = get_piece_count(changeset)

        {:noreply,
         assign(socket,
           changeset: append_piece(changeset),
           expanded_piece_index: socket.assigns.expanded_piece_index || index
         )}
      end

      def handle_event("remove-piece", %{"index" => index}, socket) do
        changeset = remove_piece(socket.assigns.changeset, parse_id(index))
        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
        {:noreply, toggle_piece_panel(socket, parse_id(index))}
      end

      # Private helpers

      defp get_appearance_count(cs), do: get_existing_items(cs, :appearances) |> length()
      defp append_appearance(cs), do: append_item(cs, :appearances, %Appearance{})
      defp remove_appearance(cs, index), do: remove_item(cs, :appearances, index)

      defp get_piece_count(cs), do: get_existing_items(cs, :pieces) |> length()
      defp append_piece(cs), do: append_item(cs, :pieces, %Piece{})
      defp remove_piece(cs, index), do: remove_item(cs, :pieces, index)

      defp append_item(cs, field, item) do
        items = get_existing_items(cs, field) ++ [item]
        Changeset.put_assoc(cs, field, items)
      end

      defp remove_item(cs, field, index) do
        items = get_existing_items(cs, field) |> List.delete_at(index)
        Changeset.put_assoc(cs, field, items)
      end

      defp get_existing_items(cs, field) do
        Map.get(cs.changes, field, [])
      end
    end
  end

  def edit do
    quote do
      def render(assigns) do
        JumubaseWeb.PerformanceView.render("live_form.html", assigns)
      end

      def mount(
            _params,
            %{"contest_id" => c_id, "performance_id" => p_id, "submit_title" => submit_title},
            socket
          ) do
        contest = Foundation.get_contest!(c_id) |> Foundation.load_contest_categories()
        performance = Showtime.get_performance!(contest, p_id)

        {:ok,
         assign(socket,
           changeset: Showtime.change_performance(performance),
           contest: contest,
           performance: performance,
           expanded_appearance_index: nil,
           expanded_piece_index: nil,
           submit_title: submit_title
         )}
      end

      def handle_event("change", %{"performance" => params}, socket) do
        contest = socket.assigns.contest
        performance = socket.assigns.performance

        changeset =
          Performance.changeset(performance, params, contest.round)
          |> Map.put(:action, :update)

        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("add-appearance", _, socket) do
        {changeset, index} = add_item(socket.assigns.changeset, :appearances, %Appearance{})

        {:noreply,
         assign(socket,
           changeset: changeset,
           expanded_appearance_index: socket.assigns.expanded_appearance_index || index
         )}
      end

      def handle_event("remove-appearance", %{"index" => index}, socket) do
        changeset = remove_item(socket.assigns.changeset, :appearances, parse_id(index))
        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("toggle-appearance-panel", %{"index" => index}, socket) do
        {:noreply, toggle_appearance_panel(socket, parse_id(index))}
      end

      def handle_event("add-piece", _, socket) do
        {changeset, index} = add_item(socket.assigns.changeset, :pieces, %Piece{})

        {:noreply,
         assign(socket,
           changeset: changeset,
           expanded_piece_index: socket.assigns.expanded_piece_index || index
         )}
      end

      def handle_event("remove-piece", %{"index" => index}, socket) do
        changeset = remove_item(socket.assigns.changeset, :pieces, parse_id(index))
        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("toggle-piece-panel", %{"index" => index}, socket) do
        {:noreply, toggle_piece_panel(socket, parse_id(index))}
      end

      # Private helpers

      defp add_item(changeset, field_name, item) do
        existing =
          changeset
          |> Changeset.get_field(field_name, [])
          |> exclude_obsolete()

        changeset = changeset |> Changeset.put_assoc(field_name, existing ++ [item])
        {changeset, length(existing)}
      end

      defp remove_item(changeset, field_name, index) do
        remaining =
          changeset
          |> Changeset.get_field(field_name, [])
          |> exclude_obsolete()
          |> List.delete_at(index)

        Changeset.put_assoc(changeset, field_name, remaining)
      end

      defp exclude_obsolete(records_or_changesets) do
        records_or_changesets
        |> Enum.filter(fn
          %Changeset{action: action} -> action in [:insert, :update]
          _ -> true
        end)
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
