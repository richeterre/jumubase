defmodule JumubaseWeb.PieceResolver do
  alias Jumubase.Showtime.Piece
  alias JumubaseWeb.Internal.PieceView

  def person_info(_, %{source: %Piece{} = pc}) do
    {:ok, PieceView.person_info(pc)}
  end
end
