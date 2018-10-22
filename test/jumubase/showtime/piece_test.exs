defmodule Jumubase.PieceTest do
  use Jumubase.DataCase
  import Ecto.Changeset
  alias Jumubase.Showtime.Piece

  describe "changeset" do
    test "is valid with valid attributes" do
      attrs = params_for(:piece)
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
    end

    test "is invalid without a title" do
      attrs = params_for(:piece, title: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without either a composer or artist" do
      attrs = params_for(:piece, composer: nil, artist: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid with both a composer and artist" do
      attrs = params_for(:piece, composer: "X", artist: "Y")
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is valid with a composer and no artist" do
      attrs = params_for(:piece, composer: "X", artist: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
    end

    test "is valid with an artist and no composer" do
      attrs = params_for(:piece, composer: nil, artist: "X")
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
    end

    test "is invalid without the composer's year of birth if composer is set" do
      attrs = params_for(:piece, composer: "X", composer_born: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is valid without the composer's year of birth if artist is set" do
      attrs = params_for(:piece, composer: nil, artist: "X", composer_born: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
    end

    test "is valid without the composer's year of death" do
      attrs = params_for(:piece, composer_died: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
    end

    test "clears all composer data when adding an artist" do
      old_piece = %Piece{composer: "X", composer_born: "1", composer_died: "2"}
      attrs = %{artist: "Y"}
      changeset = Piece.changeset(old_piece, attrs)
      assert changeset.changes == %{
        artist: "Y", composer: nil, composer_born: nil, composer_died: nil
      }
    end

    test "clears all artist data when adding a composer" do
      old_piece = %Piece{artist: "X"}
      attrs = %{composer: "Y"}
      changeset = Piece.changeset(old_piece, attrs)
      assert changeset.changes == %{artist: nil, composer: "Y"}
    end

    test "is invalid without an epoch" do
      attrs = params_for(:piece, epoch: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid with an invalid epoch" do
      for invalid_epoch <- ["", "g", "1"] do
        attrs = params_for(:piece, epoch: invalid_epoch)
        changeset = Piece.changeset(%Piece{}, attrs)
        refute changeset.valid?
      end
    end

    test "is invalid without minutes" do
      attrs = params_for(:piece, minutes: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid with invalid minutes" do
      for invalid_minutes <- ["", -1, 1.5, 60] do
        attrs = params_for(:piece, minutes: invalid_minutes)
        changeset = Piece.changeset(%Piece{}, attrs)
        refute changeset.valid?
      end
    end

    test "is invalid without seconds" do
      attrs = params_for(:piece, seconds: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid with invalid seconds" do
      for invalid_seconds <- ["", -1, 1.5, 60] do
        attrs = params_for(:piece, seconds: invalid_seconds)
        changeset = Piece.changeset(%Piece{}, attrs)
        refute changeset.valid?
      end
    end

    test "removes whitespace around the title" do
      params = params_for(:piece, title: " Air  ")
      changeset = Piece.changeset(%Piece{}, params)
      assert get_change(changeset, :title) == "Air"
    end

    test "removes whitespace around the composer" do
      params = params_for(:piece, composer: " Sylvius Leopold Weiss  ")
      changeset = Piece.changeset(%Piece{}, params)
      assert get_change(changeset, :composer) == "Sylvius Leopold Weiss"
    end

    test "removes whitespace around the composer's year of birth" do
      params = params_for(:piece, composer_born: " 1900  ")
      changeset = Piece.changeset(%Piece{}, params)
      assert get_change(changeset, :composer_born) == "1900"
    end

    test "removes whitespace around the composer's year of death" do
      params = params_for(:piece, composer_died: " 2000  ")
      changeset = Piece.changeset(%Piece{}, params)
      assert get_change(changeset, :composer_died) == "2000"
    end

    test "removes whitespace around the artist" do
      params = params_for(:piece, artist: " White Stripes  ")
      changeset = Piece.changeset(%Piece{}, params)
      assert get_change(changeset, :artist) == "White Stripes"
    end
  end
end
