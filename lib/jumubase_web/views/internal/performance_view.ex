defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [
    advancement_label: 1, age_group_badge: 1, appearance_info: 1,
    instrument_name: 1, participant_names: 1, prize: 2
  ]
  import JumubaseWeb.Internal.CategoryView, only: [genre_name: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PieceView, only: [duration: 1, epoch_tag: 1, person_info: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest, Stage}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance}
  alias JumubaseWeb.Generators.PDFGenerator

  def render("scripts.index.html", _assigns), do: render_performance_filter()

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

  def render("scripts.jury_material.html", _assigns), do: render_performance_filter()

  def render("jury_sheets.pdf", %{performances: performances, round: round}) do
    PDFGenerator.jury_sheets(performances, round)
  end

  def render("jury_table.pdf", %{performances: performances}) do
    PDFGenerator.jury_table(performances)
  end

  def render("scripts.edit_results.html", _assigns) do
    ~E(
      <script src="/js/performanceFilter.js"></script>
      <script src="/js/resultForm.js"></script>
    )
  end

  def render("scripts.publish_results.html", _assigns), do: render_performance_filter()

  def render("scripts.certificates.html", _assigns), do: render_performance_filter()

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
  Returns the performance's appearances in display order,
  i.e. soloists and ensemblists before accompanists.
  """
  def sorted_appearances(%Performance{} = p) do
    non_acc(p) ++ acc(p)
  end

  @doc """
  Returns the performance's soloist and ensemblist appearances.
  """
  def non_acc(%Performance{} = p), do: Performance.non_accompanists(p)

  @doc """
  Returns the performance's accompanist appearances.
  """
  def acc(%Performance{} = p), do: Performance.accompanists(p)

  @doc """
  Returns the performance's appearances as a nested list,
  with the grouping being decided by which ones share a common result.
  """
  def result_groups(%Performance{} = p), do: Performance.grouped_appearances(p)

  @doc """
  Gets the appearance ids from a list of appearances, in a format suitable for form submission.
  """
  def appearance_ids(appearances) when is_list(appearances) do
    get_ids(appearances) |> Enum.join(",")
  end

  @doc """
  Returns an error label if the appearance has no points, but its result is public.
  This hopefully animates the user to swiftly add the missing points.
  """
  def missing_points_error(%Appearance{points: points}, results_public) do
    if !points and results_public do
      content_tag :span, gettext("missing"),
        title: gettext("Result already published – please enter points!"),
        class: "label label-danger"
    end
  end

  def results_public_text(%Performance{results_public: true}) do
    content_tag :span, gettext("Yes")
  end
  def results_public_text(%Performance{results_public: false}) do
    content_tag :span, gettext("No"), class: "text-muted"
  end

  @doc """
  Returns various field options suitable for a filter form.
  """
  def filter_options(%Contest{} = contest) do
    %{
      stage_date_options: stage_date_filter_options(contest),
      stage_options: stage_filter_options(contest),
      genre_options: genre_filter_options(contest),
      cc_options: cc_filter_options(contest),
      ag_options: AgeGroups.all
    }
  end

  @doc """
  Returns contest category options for the contest, suitable for a filter form.
  """
  def cc_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_contest_categories
    |> Map.get(:contest_categories)
    |> Enum.map(&({&1.category.name, &1.id}))
  end

  def filter_status(count, true) do
    [count_tag(count), " ", active_filter_label()]
  end
  def filter_status(count, false), do: count_tag(count)

  # Private helpers

  defp render_performance_filter do
    ~E(<script src="/js/performanceFilter.js"></script>)
  end

  defp stage_date_filter_options(%Contest{} = contest) do
    Foundation.date_range(contest)
    |> Enum.map(&{format_date(&1), Date.to_iso8601(&1)})
  end

  defp stage_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_stages
    |> Map.get(:host)
    |> Map.get(:stages)
    |> Enum.map(&{&1.name, &1.id})
  end

  defp genre_filter_options(%Contest{round: round}) do
    genres = case round do
      0 -> ["kimu"]
      _ -> ["classical", "popular"]
    end
    Enum.map(genres, &{genre_name(&1), &1})
  end

  defp count_tag(count) do
    content_tag :span,
      ngettext("%{count} performance", "%{count} performances", count),
      class: "text-muted filter-count"
  end

  defp active_filter_label do
    content_tag :span, gettext("Filter active"), class: "label label-warning"
  end
end
