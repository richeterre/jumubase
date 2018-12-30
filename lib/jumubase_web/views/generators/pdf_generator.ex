defmodule JumubaseWeb.Generators.PDFGenerator do
  import Jumubase.Gettext
  import JumubaseWeb.DateHelpers
  import JumubaseWeb.Internal.AppearanceView, only: [acc: 1, instrument_name: 1, non_acc: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [category_name: 1, category_info: 1]
  import JumubaseWeb.Internal.PieceView, only: [duration: 1, person_info: 1]
  alias Jumubase.Showtime.{Appearance, Performance, Piece}

  @border_style "1px solid black"

  @doc """
  Returns PDF jury sheets (one per page) for the given performances.
  """
  def jury_sheets(performances) do
    render_performance_pages(performances) |> generate_pdf("portrait")
  end

  @doc """
  Returns a PDF jury table (used for collecting points) for all given performances.
  """
  def jury_table(performances) do
    render_performance_table(performances) |> generate_pdf("landscape")
  end

  # Private helpers

  defp generate_pdf(body_html, orientation) do
    html = Sneeze.render([:html,
      [:head, [:meta, %{charset: "UTF-8"}]],
      [:body,
        %{style: style(%{
          "font-family" => "DejaVu Sans",
          "font-size" => "16px",
          "line-height" => 1.4,
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

  defp render_performance_pages(performances) do
    for p <- performances do
      [:div, %{style: style(%{"page-break-before" => "always"})}, [
        [:div, %{style: style(%{"border-bottom" => @border_style})},
          [:p, [
            [:span, category_info(p)],
            [:span, format_datetime(p.stage_time)]
          ] |> to_lines]
        ],
        [:div, %{style: style(%{"margin-top" => "50px"})}, render_appearances(p)],
        [:div, %{style: style(%{"margin-top" => "200px"})}, render_pieces(p)],
      ]]
    end
  end

  defp render_appearances(%Performance{appearances: appearances}) do
    non_acc_div = [:div, non_acc(appearances) |> to_appearance_lines]
    if (acc = acc(appearances)) != [] do
      acc_div = [:div, acc |> to_appearance_lines]
      [non_acc_div, acc_heading(), acc_div]
    else
      non_acc_div
    end
  end

  defp render_appearance(%Appearance{participant: pt} = a) do
    [
      [:b, full_name(pt)],
      [:span, ", #{instrument_name(a.instrument)}"]
    ]
  end

  defp to_appearance_lines(appearances) do
    appearances |> Enum.map(&render_appearance/1) |> to_lines
  end

  defp acc_heading do
    [:div, %{style: style(%{"color" => "#666", "margin-top" => "20px"})}, gettext("accompanied by")]
  end

  defp render_pieces(%Performance{pieces: pieces}) do
    pieces |> Enum.map(&render_piece/1)
  end

  defp render_piece(%Piece{} = pc) do
    [:div, %{style: style(%{"margin-top" => "20px"})}, [
      [:b, person_info(pc)],
      [:span, pc.title],
      [:span, %{style: style(%{"color" => "#666"})},
        "#{duration(pc)} / #{gettext("Epoch")} #{pc.epoch}"
      ],
    ] |> to_lines]
  end

  defp to_lines(items), do: Enum.intersperse(items, [:br])

  defp render_performance_table(performances) do
    table = [:table,
      %{style: style(%{
        "border" => "1px solid black",
        "border-collapse" => "collapse",
        "width" => "100%"})
      },
      [:tr,
        [:th, %{style: cell_style(%{"width" => "auto"})}, gettext("Category")],
        [:th, %{style: cell_style(%{"width" => "1%", "white-space" => "nowrap"})}, gettext("Age group")],
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
    [:tr,
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

  defp render_list_appearances(%Performance{appearances: a_list}) do
    a_list |> Enum.map(&render_list_appearance/1) |> Enum.intersperse([:br])
  end

  defp render_list_appearance(%Appearance{participant: pt} = a) do
    [:span, "#{full_name(pt)}, #{instrument_name(a.instrument)}"]
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

  defp style(style_map) do
    style_map
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.join(";")
  end
end
