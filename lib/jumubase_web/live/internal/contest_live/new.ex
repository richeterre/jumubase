defmodule JumubaseWeb.Internal.ContestLive.New do
  use Phoenix.LiveView
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [name: 1, round_options: 0, grouping_options: 0]
  import JumubaseWeb.Internal.ContestLive.Helpers, only: [scrub_param: 1]
  import JumubaseWeb.PerformanceLive.Helpers, only: [parse_id: 1]
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{ContestCategory, ContestSeed}
  alias JumubaseWeb.Internal.ContestLive
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

  def handle_event("apply-template-contest", _params, socket) do
    template_c =
      Foundation.get_contest!(socket.assigns.template_contest_id)
      |> Foundation.load_contest_categories()

    changeset =
      socket.assigns.changeset
      |> replace_contest_categories(template_c.contest_categories)

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
           |> redirect(to: Routes.internal_live_path(socket, ContestLive.Index))}

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
      grouping_options: grouping_options(),
      category_options: category_options(),
      host_options: [],
      template_contest_options: [],
      template_contest_id: nil
    )
  end

  defp change(socket, attrs) do
    changeset =
      %ContestSeed{}
      |> ContestSeed.changeset(attrs)
      |> Map.put(:action, :insert)

    scrubbed_attrs = scrub_param(attrs)

    host_count = Enum.count(scrubbed_attrs["host_ids"] || [])
    season = scrubbed_attrs["season"]
    round = scrubbed_attrs["round"]
    grouping = scrubbed_attrs["grouping"]
    template_contest_id = scrubbed_attrs["template_contest_id"]

    assign(socket,
      changeset: changeset,
      host_count: host_count,
      host_options: host_options(grouping),
      template_contest_options: template_contest_options(season, round),
      template_contest_id: template_contest_id
    )
  end

  defp category_options do
    Foundation.list_categories() |> Enum.map(&{&1.name, &1.id})
  end

  defp template_contest_options(nil, _), do: []
  defp template_contest_options(_, nil), do: []

  defp template_contest_options(season, round) do
    season = String.to_integer(season)
    round = String.to_integer(round)

    Foundation.list_template_contests(season, round)
    |> Enum.map(&{name(&1), &1.id})
  end

  defp host_options(nil), do: []

  defp host_options(grouping) do
    Foundation.list_hosts_by_grouping(grouping) |> Enum.map(&{&1.name, &1.id})
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

  defp replace_contest_categories(changeset, contest_categories) do
    Changeset.put_embed(changeset, :contest_categories, contest_categories)
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
