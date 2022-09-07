defmodule JumubaseWeb.Internal.PerformanceView do
  use JumubaseWeb, :view

  import JumubaseWeb.Internal.AppearanceView,
    only: [
      advancement_label: 2,
      age_group_badge: 1,
      appearance_info: 1,
      ineligibility_warning: 3,
      instrument_name: 1,
      missing_points_error: 1,
      participant_names: 1,
      prize: 2
    ]

  import JumubaseWeb.Internal.CategoryView, only: [genre_name: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1, round_name: 1, year: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PieceView, only: [duration_and_epoch_info: 1, person_info: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest, Stage}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Performance, Results}
  alias JumubaseWeb.Internal.HostView
  alias JumubaseWeb.PDFGenerator

  def render("reschedule_success.json", %{stage_times: stage_times}) do
    stage_times
    |> Enum.map(fn {id, st} -> {id, %{stageTime: st}} end)
    |> Enum.into(%{})
  end

  def render("reschedule_failure.json", %{performance_id: p_id, errors: errors}) do
    %{
      error: %{
        performanceId: p_id,
        errors: errors
      }
    }
  end

  def render("jury_sheets.pdf", %{performances: performances, round: round}) do
    PDFGenerator.jury_sheets(performances, round)
  end

  def render("jury_table.pdf", %{performances: performances}) do
    PDFGenerator.jury_table(performances)
  end

  def stage_time(%Performance{stage_time: stage_time}) do
    format_datetime(stage_time, :time)
  end

  def stage_info(performance, style \\ :full)

  def stage_info(%Performance{stage: %Stage{} = s, stage_time: stage_time}, style) do
    {format_datetime(stage_time, style), s.name}
  end

  def stage_info(%Performance{stage: nil, stage_time: nil}, _style), do: nil

  def category_name(%Performance{} = performance) do
    performance.contest_category.category.name
  end

  def category_info(%Performance{} = performance) do
    "#{category_name(performance)}, AG #{performance.age_group}"
  end

  def predecessor_host_name(%Performance{predecessor_host: nil}), do: nil
  def predecessor_host_name(%Performance{predecessor_host: h}), do: h.name

  def predecessor_info(%Performance{predecessor_host: nil}, _), do: nil
  def predecessor_info(%Performance{predecessor_host: h}, :long), do: HostView.name_with_flag(h)
  def predecessor_info(%Performance{predecessor_host: h}, :short), do: HostView.flag(h)

  def migration_status(%Performance{successor: nil}) do
    content_tag(:span, gettext("No"), class: "text-muted")
  end

  def migration_status(%Performance{successor: _}), do: gettext("Yes")

  @doc """
  Returns the performance's formatted duration.
  """
  def formatted_duration(%Performance{} = performance) do
    Showtime.total_duration(performance)
    |> Timex.Duration.to_time!()
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
  defdelegate result_groups(performance), to: Performance

  @doc """
  Gets the appearance ids from a list of appearances, in a format suitable for form submission.
  """
  def appearance_ids(appearances) when is_list(appearances) do
    get_ids(appearances) |> Enum.join(",")
  end

  def results_public_text(%Performance{results_public: true}) do
    content_tag(:span, gettext("Yes"))
  end

  def results_public_text(%Performance{results_public: false}) do
    content_tag(:span, gettext("No"), class: "text-muted")
  end

  @doc """
  Returns various field options suitable for a filter form.
  """
  def filter_options(%Contest{round: 2} = c) do
    host_options =
      Foundation.list_performance_predecessor_hosts(c)
      |> Enum.map(&{&1.name, &1.id})

    c |> base_filter_options |> Map.put(:predecessor_host_options, host_options)
  end

  def filter_options(%Contest{round: _} = c), do: base_filter_options(c)

  @doc """
  Returns stage date options for the contest, suitable for a filter form.
  """
  def stage_date_filter_options(%Contest{} = contest) do
    Foundation.date_range(contest)
    |> Enum.map(&{format_date(&1), Date.to_iso8601(&1)})
  end

  @doc """
  Returns contest category options for the contest, suitable for a filter form.
  """
  def cc_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_contest_categories()
    |> Map.get(:contest_categories)
    |> Enum.map(fn cc ->
      {truncate(cc.category.name, 41), cc.id}
    end)
  end

  def filter_status(count, true) do
    [count_tag(count), " ", active_filter_label()]
  end

  def filter_status(count, false), do: count_tag(count)

  def certificate_instructions(0) do
    gettext(
      "Pro tip: To add a custom Kimu logo, print it on paper first, then re-insert the printed paper."
    )
  end

  def certificate_instructions(_round) do
    gettext(
      "The printed output matches the official Jumu certificate paper, which you can order %{link}.",
      link: link(gettext("here"), to: certificate_order_address()) |> safe_to_string
    )
    |> raw
  end

  def certificate_contest_text(%Contest{} = c, 1) do
    "hat am #{certificate_contest_name(c)}"
  end

  def certificate_contest_text(%Contest{} = c, _group_size) do
    "haben am #{certificate_contest_name(c)}"
  end

  def certificate_category_text(0, _, _), do: nil

  def certificate_category_text(_round, %Appearance{role: "accompanist"}, %Performance{} = p) do
    assigns = %{category_name: category_name(p), age_group: p.age_group}

    ~H"""
    <span>in der Wertung für <i>Instrumentalbegleitung</i></span>
    <br>
    <span>in der Kategorie <i><%= @category_name %>, AG <%= @age_group %></i></span>
    """
  end

  def certificate_category_text(_round, %Appearance{}, %Performance{} = p) do
    assigns = %{category_name: category_name(p)}

    ~H"""
    <span>in der Wertung für <i><%= @category_name %></i></span>
    <br>
    """
  end

  def certificate_rating_points_text(0, _, _), do: "teilgenommen."

  def certificate_rating_points_text(round, points, group_size) do
    assigns = %{
      rating: Results.get_rating(points, round),
      points_text: certificate_points_text(points, group_size)
    }

    ~H"""
    <span><%= @rating || "teilgenommen" %></span>
    <br>
    <span><%= @points_text %></span>
    """
  end

  def certificate_prize_text(0, %Appearance{points: points}, _performance) do
    assigns = %{rating: Results.get_rating(points, 0)}

    ~H"""
    <b>Zuerkannt wurde das Prädikat: <%= @rating %></b>
    """
  end

  def certificate_prize_text(round, %Appearance{points: points} = a, %Performance{} = p) do
    case Results.get_prize(points, round) do
      nil ->
        nil

      prize ->
        assigns = %{prize: prize, advancement_text: certificate_advancement_text(a, p, round)}

        ~H"""
        <b>Zuerkannt wurde ein <%= @prize %></b>
        <br>
        <span><%= @advancement_text %></span>
        """
    end
  end

  def certificate_date_text(%Contest{host: h, end_date: end_date, certificate_date: cert_date}) do
    "#{h.city}, den #{format_date(cert_date || end_date)}"
  end

  def certificate_signatures_text(0) do
    assigns = %{}
    ~H"<span>Für die Jury</span>"
  end

  def certificate_signatures_text(round) when round in 1..2 do
    assigns = %{committee_name: certificate_committee_name(round)}

    ~H"""
    <span>Für den <%= @committee_name %></span>
    <span>Für die Jury</span>
    """
  end

  # Private helpers

  defp base_filter_options(%Contest{} = contest) do
    %{
      stage_date_options: stage_date_filter_options(contest),
      stage_options: stage_filter_options(contest),
      genre_options: genre_filter_options(contest),
      cc_options: cc_filter_options(contest),
      ag_options: AgeGroups.all()
    }
  end

  defp stage_filter_options(%Contest{} = contest) do
    contest
    |> Foundation.load_used_stages()
    |> Map.get(:host)
    |> Map.get(:stages)
    |> Enum.map(&{&1.name, &1.id})
  end

  defp genre_filter_options(%Contest{round: round}) do
    genres =
      case round do
        0 -> ["kimu"]
        _ -> ["classical", "popular"]
      end

    Enum.map(genres, &{genre_name(&1), &1})
  end

  defp truncate(text, max_length) do
    if String.length(text) < max_length,
      do: text,
      else: "#{String.slice(text, 0, max_length - 1)}…"
  end

  defp count_tag(count) do
    content_tag(
      :span,
      ngettext("%{count} performance", "%{count} performances", count),
      class: "text-muted"
    )
  end

  defp active_filter_label do
    content_tag(:span, gettext("Filter active"), class: "label label-warning")
  end

  defp certificate_order_address do
    "mailto:jumu@musikrat.de?subject=Urkundenpapier"
  end

  defp certificate_contest_name(%Contest{host: h} = c) do
    "#{certificate_round_text(c.round)} #{h.name} #{year(c)}"
  end

  defp certificate_round_text(0), do: "Wettbewerb „Kinder musizieren“"
  defp certificate_round_text(round), do: round_name(round)

  defp certificate_points_text(points, 1), do: "und erreichte #{points} Punkte."
  defp certificate_points_text(points, _group_size), do: "und erreichten #{points} Punkte."

  defp certificate_advancement_text(%Appearance{} = a, %Performance{} = p, round) do
    cond do
      Results.advances?(a, p) ->
        "mit der Berechtigung zur Teilnahme am #{round_name(round + 1)}."

      Results.gets_wespe_nomination?(a, p) ->
        "mit Nominierung zur Teilnahme am Wochenende der Sonderpreise (WESPE)."

      true ->
        nil
    end
  end

  defp certificate_committee_name(1), do: "Regionalausschuss"
  defp certificate_committee_name(2), do: "Landesausschuss"
end
