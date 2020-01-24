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

  @doc """
  Returns HTML element(s) describing the piece's duration and epoch.
  """
  def duration_and_epoch_info(%Piece{epoch: "trad"} = pc) do
    duration(pc)
  end

  def duration_and_epoch_info(%Piece{epoch: epoch} = pc) do
    [duration(pc), " / #{gettext("Epoch")} ", epoch_tag(epoch)]
  end

  # Private helpers

  defp pad_seconds(sec) do
    sec |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  defp epoch_tag(epoch) do
    content_tag(:abbr, epoch, title: JumuParams.epoch_description(epoch))
  end
end
