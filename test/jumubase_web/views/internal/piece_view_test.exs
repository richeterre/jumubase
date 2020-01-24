defmodule JumubaseWeb.Internal.PieceViewTest do
  use JumubaseWeb.ConnCase, async: true
  import Phoenix.HTML
  alias JumubaseWeb.Internal.PieceView

  describe "person_info/1" do
    test "returns the name and birthyear of a classical piece's living composer" do
      piece = build(:piece, composer: "Keiko Abe", composer_born: "1937", composer_died: nil)
      assert PieceView.person_info(piece) == "Keiko Abe (1937–)"
    end

    test "returns the name and lifespan of a classical piece's deceased composer" do
      piece = build(:piece, composer: "John Cage", composer_born: "1912", composer_died: "1992")
      assert PieceView.person_info(piece) == "John Cage (1912–1992)"
    end

    test "returns the name of a popular piece's artist" do
      piece = build(:popular_piece, artist: "Johnny Cash")
      assert PieceView.person_info(piece) == "Johnny Cash"
    end

    test "returns special text for a traditional piece with no artist or composer" do
      piece = build(:piece, composer: nil, artist: nil, epoch: "trad")
      assert PieceView.person_info(piece) == "Trad."
    end
  end

  describe "duration/1" do
    test "returns a piece's duration" do
      piece = build(:piece, minutes: 4, seconds: 3)
      assert PieceView.duration(piece) == "4'03"
    end
  end

  describe "duration_and_epoch_info/1" do
    test "returns duration and epoch information for a traditional piece" do
      piece = build(:piece, epoch: "trad", minutes: 4, seconds: 3)

      assert PieceView.duration_and_epoch_info(piece) == "4'03"
    end

    test "returns duration and epoch information for a non-traditional piece" do
      piece = build(:piece, epoch: "b", minutes: 4, seconds: 3)

      assert PieceView.duration_and_epoch_info(piece) |> html_escape() |> safe_to_string ==
               "4&#39;03 / Epoch <abbr title=\"Baroque\">b</abbr>"
    end
  end
end
