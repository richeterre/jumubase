defmodule JumubaseWeb.Internal.PieceView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.Piece

  @doc """
  Returns the the piece's composer or artist name.
  """
  def person_name(%Piece{composer: nil, artist: artist}), do: artist
  def person_name(%Piece{composer: composer, artist: nil}), do: composer

  def composer_dates(%Piece{composer: nil}), do: nil
  def composer_dates(%Piece{composer_born: nil}), do: nil
  def composer_dates(%Piece{composer_born: born, composer_died: died}) do
    "#{born}–#{died}"
  end

  @doc """
  Returns the piece's formatted duration.
  """
  def duration(%Piece{minutes: min, seconds: sec}) do
    "#{min}'#{sec}"
  end

  @doc """
  Returns a textual tag describing the piece's epoch.
  """
  def epoch_tag(%Piece{epoch: epoch}) do
    content_tag(:abbr, epoch, title: JumuParams.epoch_description(epoch))
  end
end
