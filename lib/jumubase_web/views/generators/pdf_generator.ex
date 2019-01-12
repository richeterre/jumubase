defmodule JumubaseWeb.Generators.PDFGenerator do
  import Jumubase.Gettext
  import JumubaseWeb.DateHelpers
  import JumubaseWeb.Internal.AppearanceView, only: [appearance_info: 1, instrument_name: 1]
  import JumubaseWeb.Internal.ContestView, only: [round_name: 1, year: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PerformanceView,
    only: [acc: 1, category_name: 1, category_info: 1, non_acc: 1, result_groups: 1]
  import JumubaseWeb.Internal.PieceView, only: [duration: 1, person_info: 1]
  alias Jumubase.Foundation.Contest
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias Jumubase.Showtime.Results

  @border_style "1px solid black"
  @muted_color "#666"

  @doc """
  Returns PDF jury sheets (one per page) for the given performances.
  """
  def jury_sheets(performances, round) do
    render_performance_pages(performances, round) |> generate_pdf("portrait")
  end

  @doc """
  Returns a PDF jury table (used for collecting points) for all given performances.
  """
  def jury_table(performances) do
    render_performance_table(performances) |> generate_pdf("landscape")
  end

  def certificates(performances, contest) do
    render_certificate_pages(performances, contest) |> generate_pdf("portrait")
  end

  # Private helpers

  defp generate_pdf(body_html, orientation) do
    html = Sneeze.render([:html,
      [:head, [:meta, %{charset: "UTF-8"}]],
      [:body,
        %{style: style(%{
          "font-family" => "LatoLatin",
          "font-size" => "18px",
          "line-height" => 1.3,
        })},
        body_html
      ]
    ])

    base_params = ["--disable-smart-shrinking", "--orientation", orientation, "--quiet"]

    # Adjust zoom level to account for different DPI, using Mac (96 dpi) as baseline
    shell_params = case :os.type do
      {:unix, :linux} ->
        base_params ++ ["--zoom", "0.78125"] # 75 dpi / 96 dpi
      _ ->
        base_params
    end

    PdfGenerator.generate_binary!(html,
      page_size: "A4",
      shell_params: shell_params
    )
  end

  defp render_performance_pages(performances, round) do
    for p <- performances do
      [:div, %{style: style(%{"page-break-before" => "always"})},
        [:div, %{style: style(%{"border-bottom" => @border_style, "height" => "55px"})},
          [:p, [
            [:span, category_info(p)],
            [:span, format_datetime(p.stage_time)]
          ] |> to_lines]
        ],
        [:div, %{style: style(%{"margin-top" => "50px", "height" => "300px"})}, render_appearances(p)],
        [:div, %{style: style(%{"height" => "580px"})}, render_pieces(p)],
        [:div, %{style: style(%{"height" => "50px"})}, render_point_ranges(round)],
      ]
    end
  end

  defp render_appearances(%Performance{age_group: ag} = p) do
    non_acc_div = [:div, non_acc(p) |> to_appearance_lines(ag)]
    if (acc = acc(p)) != [] do
      acc_div = [:div, acc |> to_appearance_lines(ag)]
      [non_acc_div, acc_heading(), acc_div]
    else
      non_acc_div
    end
  end

  defp to_appearance_lines(appearances, performance_ag) do
    appearances
    |> Enum.map(fn a ->
      ag_info = age_group_info(a, performance_ag)
      [
        [:b, "#{full_name(a.participant)},"],
        [:span, " #{instrument_name(a.instrument)} #{ag_info}"]
      ]
    end)
    |> to_lines
  end

  defp acc_heading do
    [:div, %{style: style(%{"color" => @muted_color, "line-height" => 2})},
      gettext("accompanied by")
    ]
  end

  defp render_pieces(%Performance{pieces: pieces}) do
    pieces |> Enum.map(&render_piece/1)
  end

  defp render_piece(%Piece{} = pc) do
    [:div, %{style: style(%{"margin-bottom" => "20px"})}, [
      [:b, person_info(pc)],
      [:span, pc.title],
      [:span, %{style: style(%{"color" => @muted_color})},
        "#{duration(pc)} / #{gettext("Epoch")} #{pc.epoch}"
      ],
    ] |> to_lines]
  end

  defp render_point_ranges(round) do
    {left_side, right_side} =
      Results.prizes_for_round(round)
      |> Map.merge(Results.ratings_for_round(round))
      |> Enum.reverse
      |> Enum.split(3)

    [:div, %{style: style(%{"color" => @muted_color, "font-size" => "12px"})},
      format_point_ranges(left_side),
      format_point_ranges(right_side)
    ]
  end

  defp format_point_ranges(point_ranges) do
    [:div, %{style: style(%{"display" => "inline-block", "vertical-align" => "top", "width" => "50%"})},
      point_ranges |> Enum.map(&format_point_range/1) |> to_lines
    ]
  end

  defp format_point_range({first..last, text}) do
    [:span, "#{first}–#{last} #{gettext("points")}: #{text}"]
  end

  defp to_lines(items), do: Enum.intersperse(items, [:br])

  defp render_performance_table(performances) do
    table = [:table,
      %{style: style(%{
        "border" => "1px solid black",
        "border-collapse" => "collapse",
        "page-break-inside" => "auto",
        "width" => "100%"})
      },
      [:tr,
        [:th, %{style: cell_style(%{"width" => "auto"})}, gettext("Category")],
        [:th, %{style: cell_style(%{"width" => "1%", "white-space" => "nowrap"})}, gettext("AG")],
        [:th, %{style: cell_style(%{"width" => "auto"})}, gettext("Participants")],
        [:th, %{style: cell_style(%{"width" => "5%"})}, "J1"],
        [:th, %{style: cell_style(%{"width" => "5%"})}, "J2"],
        [:th, %{style: cell_style(%{"width" => "5%"})}, "J3"],
        [:th, %{style: cell_style(%{"width" => "5%"})}, "J4"],
        [:th, %{style: cell_style(%{"width" => "5%"})}, "J5"],
        [:th, %{style: cell_style(%{"width" => "10%"})}, gettext("Result")],
      ]
    ]
    performance_rows = Enum.map(performances, &render_performance_row/1)
    table ++ performance_rows
  end

  defp render_performance_row(%Performance{} = p) do
    [:tr, %{style: style(%{"page-break-inside" => "avoid", "page-break-after" => "auto"})},
      [:td, %{style: cell_style()}, category_name(p)],
      [:td, %{style: cell_style()}, p.age_group],
      [:td, %{style: cell_style()}, render_list_appearances(p)],
      [:td, %{style: cell_style()}],
      [:td, %{style: cell_style()}],
      [:td, %{style: cell_style()}],
      [:td, %{style: cell_style()}],
      [:td, %{style: cell_style()}],
      [:td, %{style: cell_style()}],
    ]
  end

  defp render_list_appearances(%Performance{age_group: p_ag} = p) do
    non_acc = non_acc(p) |> Enum.map(&render_list_appearance(&1, p_ag)) |> to_lines
    acc = acc(p) |> Enum.map(&render_list_appearance(&1, p_ag)) |> to_lines

    if acc != [], do: non_acc ++ [acc_heading()] ++ acc, else: non_acc
  end

  defp render_list_appearance(%Appearance{} = a, performance_ag) do
    ag_info = age_group_info(a, performance_ag)
    [:span, "#{full_name(a.participant)}, #{instrument_name(a.instrument)} #{ag_info}"]
  end

  defp age_group_info(%Appearance{age_group: ag}, performance_ag) do
    if ag != performance_ag, do: "(AG #{ag})", else: nil
  end

  defp cell_style(style_map \\ %{}) do
    %{
      "border" => @border_style,
      "padding" => "10px",
      "text-align" => "left",
      "vertical-align" => "top"
    }
    |> Map.merge(style_map)
    |> style
  end

  defp render_certificate_pages(performances, contest) do
    for p <- performances do
      for group <- result_groups(p) do
        for a <- group do
          group_size = length(group)
          [:div, %{style: style(%{"page-break-before" => "always"})},
            [:p,
              [:b, group |> Enum.map(&([:span, appearance_info(&1)])) |> to_lines],
            ],
            [:p,
              [
                [:span, contest_text(contest, group_size)],
                [:span, "für das instrumentale und vokale Musizieren der Jugend"],
                [:span, category_text(contest.round, a, p)],
              ] |> to_lines
            ],
            [:p,
              [
                [:span, "in der Altersgruppe #{a.age_group}"],
                [:span, rating_points_text(contest.round, a.points, group_size)],
              ] |> to_lines
            ],
            [:p, prize_text(contest.round, a)],
            [:p, date_text(contest)],
            [:p, signatures_text(contest.round)],
          ]
        end
      end
    end
  end

  defp contest_text(%Contest{} = c, 1), do: "hat am #{contest_name(c)}"
  defp contest_text(%Contest{} = c, _group_size), do: "haben am #{contest_name(c)}"

  defp contest_name(%Contest{host: h} = c) do
    "#{round_text(c.round)} in #{h.city} #{year(c)}"
  end

  defp round_text(0), do: "Wettbewerb „Kinder musizieren“"
  defp round_text(round), do: round_name(round)

  defp category_text(0, _, _), do: nil
  defp category_text(_round, %Appearance{role: "accompanist"}, %Performance{} = p) do
    [
      [[:span, "in der Wertung für "], [:i, "Instrumentalbegleitung"]],
      [[:span, "in der Kategorie "], [:i, "#{category_name(p)}, AG #{p.age_group}"]]
    ] |> to_lines
  end
  defp category_text(_round, %Appearance{}, %Performance{} = p) do
    [[:span, "in der Wertung für "], [:i, category_name(p)]]
  end

  defp rating_points_text(0, _, _), do: "teilgenommen."
  defp rating_points_text(round, points, group_size) do
    [
      [:span, Results.get_rating(points, round) || "teilgenommen"],
      [:span, points_text(points, group_size)],
    ] |> to_lines
  end

  defp points_text(points, 1), do: "und erreichte #{points} Punkte."
  defp points_text(points, _group_size), do: "und erreichten #{points} Punkte."

  defp prize_text(0, %Appearance{points: points}) do
    [:b, "Zuerkannt wurde das Prädikat: #{Results.get_rating(points, 0)}"]
  end
  defp prize_text(round, %Appearance{points: points} = a) do
    case Results.get_prize(points, round) do
      nil -> nil
      prize -> [
        [:b, "Zuerkannt wurde ein #{prize}"],
        [:span, advancement_text(a, round)]
      ] |> to_lines
    end
  end

  defp advancement_text(%Appearance{role: "accompanist"}, _round), do: nil
  defp advancement_text(%Appearance{} = a, round) do
    if Results.advances?(a) do
      "mit der Berechtigung zur Teilnahme am #{round_name(round + 1)}."
    end
  end

  defp date_text(%Contest{host: h, end_date: end_date, certificate_date: cert_date}) do
    "#{h.city}, den #{format_date(cert_date || end_date)}"
  end

  defp signatures_text(0), do: [:p, "Für die Jury"]
  defp signatures_text(round) when round in 1..2 do
    [
      [:span, "Für den #{committee_name(round)}"],
      [:span, %{style: style(%{"margin-left" => "200px"})}, "Für die Jury"],
    ]
  end

  defp committee_name(1), do: "Regionalausschuss"
  defp committee_name(2), do: "Landesausschuss"

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.join(";")
  end
end
