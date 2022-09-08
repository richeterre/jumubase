defmodule JumubaseWeb.PDFGenerator.DefaultEngine do
  @moduledoc """
  PDF generator engine that returns actual PDF binaries.
  """

  @behaviour JumubaseWeb.PDFGenerator.Engine

  import Jumubase.Gettext
  import JumubaseWeb.DateHelpers
  import JumubaseWeb.Internal.AppearanceView, only: [instrument_name: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]

  import JumubaseWeb.Internal.PerformanceView,
    only: [
      acc: 1,
      category_info: 1,
      non_acc: 1,
      predecessor_host_name: 1
    ]

  import JumubaseWeb.Internal.PieceView, only: [duration: 1, person_info: 1]
  alias Jumubase.Showtime.{Appearance, Performance, Piece}
  alias Jumubase.Showtime.Results

  @border_style "1px solid black"
  @line_height_factor 1.3
  @muted_color "#666"

  @doc """
  Returns PDF jury sheets (one per page) for the given performances.
  """
  def jury_sheets(performances, round) do
    render_performance_pages(performances, round) |> generate_pdf("portrait")
  end

  # Private helpers

  defp generate_pdf(body_html, orientation, font_size \\ "18px") do
    html =
      Sneeze.render([
        :html,
        [:head, [:meta, %{charset: "UTF-8"}]],
        [
          :body,
          style(%{
            "font-family" => "LatoLatin",
            "font-size" => font_size,
            "line-height" => @line_height_factor
          }),
          body_html
        ]
      ])

    base_params = ["--disable-smart-shrinking", "--orientation", orientation]

    # Adjust zoom level to account for different DPI, using Mac (96 dpi) as baseline
    shell_params =
      case :os.type() do
        {:unix, :linux} ->
          # 75 dpi / 96 dpi
          base_params ++ ["--zoom", "0.78125"]

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
      [
        :div,
        style(%{"page-break-before" => "always"}),
        [
          :div,
          style(%{"border-bottom" => @border_style, "height" => "55px"}),
          [
            [
              :div,
              style(%{"float" => "left"}),
              [
                [:span, category_info(p)],
                [:span, format_datetime(p.stage_time)]
              ]
              |> to_lines
            ],
            [
              :div,
              style(%{"float" => "right"}),
              [:br, [:span, predecessor_host_name(p)]]
            ]
          ]
        ],
        [
          :div,
          style(%{"margin-top" => "50px", "height" => "250px"}),
          render_appearances(p)
        ],
        [:div, style(%{"height" => "630px"}), render_pieces(p)],
        [:div, style(%{"height" => "50px"}), render_point_ranges(round)]
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
    [
      :div,
      style(%{"color" => @muted_color, "line-height" => 2}),
      gettext("accompanied by")
    ]
  end

  defp render_pieces(%Performance{pieces: pieces}) do
    pieces |> Enum.map(&render_piece/1)
  end

  defp render_piece(%Piece{} = pc) do
    [
      :div,
      style(%{"margin-bottom" => "20px"}),
      [
        [:b, person_info(pc)],
        [:span, pc.title],
        [
          :span,
          style(%{"color" => @muted_color}),
          duration_and_epoch_text(pc)
        ]
      ]
      |> to_lines
    ]
  end

  defp duration_and_epoch_text(%Piece{epoch: nil} = pc), do: duration(pc)
  defp duration_and_epoch_text(%Piece{epoch: "trad"} = pc), do: duration(pc)

  defp duration_and_epoch_text(%Piece{} = pc) do
    "#{duration(pc)} / #{epoch_text(pc)}"
  end

  defp epoch_text(%Piece{epoch: epoch}) do
    "#{gettext("Epoch")} #{epoch}"
  end

  defp render_point_ranges(round) do
    {left_side, right_side} =
      Results.prizes_for_round(round)
      |> Map.merge(Results.ratings_for_round(round))
      |> Enum.reverse()
      |> Enum.split(3)

    [
      :div,
      style(%{"color" => @muted_color, "font-size" => "12px"}),
      format_point_ranges(left_side),
      format_point_ranges(right_side)
    ]
  end

  defp format_point_ranges(point_ranges) do
    [
      :div,
      style(%{"display" => "inline-block", "vertical-align" => "top", "width" => "50%"}),
      point_ranges |> Enum.map(&format_point_range/1) |> to_lines
    ]
  end

  defp format_point_range({first..last, text}) do
    [:span, "#{first}–#{last} #{gettext("points")}: #{text}"]
  end

  defp to_lines(items), do: Enum.intersperse(items, [:br])

  defp age_group_info(%Appearance{age_group: ag}, performance_ag) do
    if ag != performance_ag, do: "(AG #{ag})", else: nil
  end

  defp style(style_map) do
    style_string =
      style_map
      |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
      |> Enum.join(";")

    %{"style" => style_string}
  end
end
