defmodule JumubaseWeb.Internal.PieceViewTest do
  use JumubaseWeb.ConnCase, async: true
  import Phoenix.HTML
  alias JumubaseWeb.Internal.PieceView

  describe "person_name/1" do
    test "returns the name of a classical piece's composer" do
      piece = build(:piece, composer: "John Cage")
      assert PieceView.person_name(piece) == "John Cage"
    end

    test "returns the name of a popular piece's artist" do
      piece = build(:popular_piece, artist: "Johnny Cash")
      assert PieceView.person_name(piece) == "Johnny Cash"
    end
  end

  describe "composer_dates/1" do
    test "returns the birthyear of a piece's living composer" do
      piece = build(:piece, composer_born: "1956", composer_died: nil)
      assert PieceView.composer_dates(piece) == "1956–"
    end

    test "returns the lifespan of a piece's deceased composer" do
      piece = build(:piece, composer_born: "1902", composer_died: "2001")
      assert PieceView.composer_dates(piece) == "1902–2001"
    end

    test "returns nil if the piece has no composer" do
      piece = build(:piece, composer: nil)
      assert PieceView.composer_dates(piece) == nil
    end

    test "returns nil if the piece has no composer birthyear" do
      piece = build(:piece, composer_born: nil)
      assert PieceView.composer_dates(piece) == nil
    end
  end

  test "duration/1 returns a piece's duration" do
    piece = build(:piece, minutes: 4, seconds: 33)
    assert PieceView.duration(piece) == "4'33"
  end

  test "epoch_tag/1 returns an epoch tag for a piece" do
    piece = build(:piece, epoch: "b")
    assert PieceView.epoch_tag(piece) |> safe_to_string ==
      "<abbr title=\"Baroque\">b</abbr>"
  end
end
