defmodule JumubaseWeb.Internal.ContestLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [round_options: 0]
  alias Ecto.Changeset
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{ContestCategory, ContestSeed}
  alias JumubaseWeb.Router.Helpers, as: Routes

  def render(assigns) do
    JumubaseWeb.Internal.ContestView.render("live_form.html", assigns)
  end

  def mount(_params, _assigns, socket) do
    {:ok, prepare(socket)}
  end

  def handle_event("change", %{"contest_seed" => attrs}, socket) do
    {:noreply, change(socket, attrs)}
  end

  def handle_event("add-contest-category", _params, socket) do
    changeset =
      socket.assigns.changeset
      |> append_contest_category()

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", %{"contest_seed" => attrs}, socket) do
    changeset = ContestSeed.changeset(%ContestSeed{}, attrs)

    if changeset.valid? do
      seed = Changeset.apply_changes(changeset)

      # TODO
      hosts = [
        Jumubase.Repo.get(Jumubase.Foundation.Host, 1)
      ]

      case Foundation.create_contests(seed, hosts) do
        {:ok, result} ->
          message =
            ngettext(
              "CONTEST_CREATION_SUCCESS_ONE",
              "CONTEST_CREATION_SUCCESS_MANY",
              map_size(result)
            )

          {:noreply,
           socket
           |> put_flash(:success, message)
           |> redirect(to: Routes.internal_contest_path(socket, :index))}

        {:error, _, _, _} ->
          {:noreply, socket}
      end
    else
      changeset = %{changeset | action: :validate}
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Private helpers

  defp prepare(socket) do
    changeset =
      Changeset.change(%ContestSeed{})
      |> append_contest_category()

    assign(socket,
      changeset: changeset,
      round_options: round_options(),
      category_options: category_options()
    )
  end

  defp change(socket, attrs) do
    changeset =
      %ContestSeed{}
      |> ContestSeed.changeset(attrs)
      |> Map.put(:action, :insert)

    assign(socket, changeset: changeset)
  end

  defp category_options do
    Foundation.list_categories() |> Enum.map(&{&1.name, &1.id})
  end

  defp append_contest_category(changeset) do
    new_cs = Changeset.change(%ContestCategory{})
    existing = Changeset.get_change(changeset, :contest_categories, [])
    Changeset.put_embed(changeset, :contest_categories, existing ++ [new_cs])
  end
end
