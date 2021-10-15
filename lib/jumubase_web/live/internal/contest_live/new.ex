defmodule JumubaseWeb.Internal.ContestLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [round_options: 0]
  import JumubaseWeb.PerformanceLive.Helpers, only: [parse_id: 1]
  alias Ecto.Changeset
  alias Jumubase.JumuParams
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
    changeset = socket.assigns.changeset |> append_contest_category()
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-contest-category", %{"index" => index}, socket) do
    index = parse_id(index)
    changeset = socket.assigns.changeset |> remove_contest_category(index)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("move-contest-category-up", %{"index" => index}, socket) do
    index = parse_id(index)
    changeset = socket.assigns.changeset |> swap_contest_categories(index, index - 1)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("move-contest-category-down", %{"index" => index}, socket) do
    index = parse_id(index)
    changeset = socket.assigns.changeset |> swap_contest_categories(index, index + 1)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", %{"contest_seed" => attrs}, socket) do
    changeset = ContestSeed.changeset(%ContestSeed{}, attrs)
    host_ids = attrs["host_ids"]

    if changeset.valid? and host_ids do
      seed = Changeset.apply_changes(changeset)
      hosts = Foundation.list_hosts(host_ids)

      case Foundation.create_contests(seed, hosts) do
        {:ok, result} ->
          message =
            ngettext(
              "The contest was created.",
              "The contests were created.",
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
      Changeset.change(%ContestSeed{}, %{season: current_season()})
      |> append_contest_category()

    assign(socket,
      changeset: changeset,
      host_count: 0,
      round_options: round_options(),
      category_options: category_options(),
      host_options: host_options()
    )
  end

  defp change(socket, attrs) do
    changeset =
      %ContestSeed{}
      |> ContestSeed.changeset(attrs)
      |> Map.put(:action, :insert)

    host_count = Enum.count(attrs["host_ids"] || [])

    assign(socket, changeset: changeset, host_count: host_count)
  end

  defp category_options do
    Foundation.list_categories() |> Enum.map(&{&1.name, &1.id})
  end

  defp host_options do
    Foundation.list_hosts() |> Enum.map(&{&1.name, &1.id})
  end

  defp append_contest_category(changeset) do
    new_cs = Changeset.change(%ContestCategory{})
    contest_categories = get_existing_contest_categories(changeset) ++ [new_cs]
    Changeset.put_embed(changeset, :contest_categories, contest_categories)
  end

  defp remove_contest_category(changeset, index) do
    contest_categories = get_existing_contest_categories(changeset) |> List.delete_at(index)
    Changeset.put_embed(changeset, :contest_categories, contest_categories)
  end

  defp swap_contest_categories(changeset, idx1, idx2) do
    contest_categories = get_existing_contest_categories(changeset)

    if min(idx1, idx2) < 0 or max(idx1, idx2) > length(contest_categories) - 1 do
      changeset
    else
      item1 = Enum.at(contest_categories, idx1)
      item2 = Enum.at(contest_categories, idx2)

      contest_categories =
        contest_categories
        |> List.replace_at(idx1, item2)
        |> List.replace_at(idx2, item1)

      Changeset.put_embed(changeset, :contest_categories, contest_categories)
    end
  end

  defp get_existing_contest_categories(changeset) do
    Changeset.get_change(changeset, :contest_categories, [])
  end

  defp current_season do
    today = Timex.today()

    if today.month > 6 do
      JumuParams.season(today.year + 1)
    else
      JumuParams.season(today.year)
    end
  end
end
