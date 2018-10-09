defmodule Jumubase.PieceTest do
  use Jumubase.DataCase
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

    test "is invalid without a composer name" do
      attrs = params_for(:piece, composer_name: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without the composer's year of birth" do
      attrs = params_for(:piece, composer_born: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      refute changeset.valid?
    end

    test "is valid without the composer's year of death" do
      attrs = params_for(:piece, composer_died: nil)
      changeset = Piece.changeset(%Piece{}, attrs)
      assert changeset.valid?
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
  end
end
