defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [
    acc: 1, age_group_badge: 1, instrument_name: 1, non_acc: 1
  ]
  import JumubaseWeb.Internal.CategoryView, only: [genre_name: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PieceView, only: [
    composer_dates: 1, duration: 1, epoch_tag: 1, person_name: 1
  ]
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest, Stage}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  def render("scripts.index.html", _assigns) do
    ~E(<script src="/js/performanceFilter.js"></script>)
  end

  def render("scripts.new.html", assigns) do
    # Load same script as in public registration form
    JumubaseWeb.PerformanceView.render("scripts.new.html", assigns)
  end

  def render("scripts.edit.html", assigns) do
    # Load same script as in public registration form
    JumubaseWeb.PerformanceView.render("scripts.edit.html", assigns)
  end

  def render("reschedule_success.json", %{stage_times: stage_times}) do
    stage_times
    |> Enum.map(fn {id, st} -> {id, %{stageTime: st}} end)
    |> Enum.into(%{})
  end

  def render("reschedule_failure.json", %{performance_id: p_id, errors: errors}) do
    %{error: %{
      performanceId: p_id,
      errors: errors
    }}
  end

  def stage_info(performance, style \\ :full)
  def stage_info(%Performance{stage: %Stage{name: name}, stage_time: stage_time}, style) do
    {format_datetime(stage_time, style), name}
  end
  def stage_info(%Performance{stage: nil, stage_time: nil}, _style), do: nil

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end

  def category_info(%Performance{} = performance) do
    "#{category_name(performance)}, AG #{performance.age_group}"
  end

  @doc """
  Returns the performance's formatted duration.
  """
  def formatted_duration(%Performance{} = performance) do
    Showtime.total_duration(performance)
    |> Timex.Duration.to_time!
    |> Timex.format!("%-M'%S", :strftime)
  end

  @doc """
  Returns the contest's dates, suitable for a filter form.
  """
  def stage_date_filter_options(%Contest{} = contest) do
    Foundation.date_range(contest)
    |> Enum.map(&{format_date(&1), Date.to_iso8601(&1)})
  end

  @doc """
  Returns the contest's dates, suitable for a filter form.
  """
  def stage_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_stages
    |> Map.get(:host)
    |> Map.get(:stages)
    |> Enum.map(&{&1.name, &1.id})
  end

  @doc """
  Returns genres relevant to the contest, suitable for a filter form.
  """
  def genre_filter_options(%Contest{round: round}) do
    genres = case round do
      0 -> ["kimu"]
      _ -> ["classical", "popular"]
    end
    Enum.map(genres, &{genre_name(&1), &1})
  end

  @doc """
  Returns contest categories relevant to the contest, suitable for a filter form.
  """
  def cc_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_contest_categories
    |> Map.get(:contest_categories)
    |> Enum.map(&({&1.category.name, &1.id}))
  end

  @doc """
  Returns age groups suitable for a filter form.
  """
  def ag_filter_options, do: AgeGroups.all

  def filter_status(count, true) do
    [count_tag(count), " ", active_filter_label()]
  end
  def filter_status(count, false), do: count_tag(count)

  # Private helpers


  defp count_tag(count) do
    content_tag :span,
      ngettext("%{count} performance", "%{count} performances", count),
      class: "text-muted filter-count"
  end

  defp active_filter_label do
    content_tag :span, gettext("Filter active"), class: "label label-warning"
  end
end
