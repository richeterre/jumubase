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
  Returns a textual tag describing the piece's epoch.
  """
  def epoch_tag(%Piece{epoch: epoch}) do
    content_tag(:abbr, epoch, title: JumuParams.epoch_description(epoch))
  end

  # Private helpers

  defp pad_seconds(sec) do
    sec |> Integer.to_string() |> String.pad_leading(2, "0")
  end
end
