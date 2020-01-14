defmodule JumubaseWeb.Internal.PieceView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.Piece

  @doc """
  Returns the piece's composer or artist info.
  """
  def person_info(%Piece{composer: nil, artist: artist}), do: artist

  def person_info(%Piece{composer: composer, artist: nil} = pc) do
    %{composer_born: born, composer_died: died} = pc
    "#{composer} (#{born}–#{died})"
  end

  @doc """
  Returns the piece's formatted duration.
  """
  def duration(%Piece{minutes: min, seconds: sec}) do
    "#{min}'#{pad_seconds(sec)}"
  end

  def epoch_text(%Piece{} = pc) do
    case pc.epoch do
      "trad" -> "trad."
      epoch -> "#{gettext("Epoch")} #{epoch}"
    end
  end

  @doc """
  Returns HTML element(s) describing the piece's epoch.
  """
  def epoch_info("trad" = epoch), do: epoch_tag(epoch)

  def epoch_info(epoch) do
    "#{gettext("Epoch")} #{safe_to_string(epoch_tag(epoch))}" |> raw
  end

  # Private helpers

  defp pad_seconds(sec) do
    sec |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  defp epoch_tag("trad" = epoch) do
    content_tag(:abbr, "trad.", title: JumuParams.epoch_description(epoch))
  end

  defp epoch_tag(epoch) do
    content_tag(:abbr, epoch, title: JumuParams.epoch_description(epoch))
  end
end
