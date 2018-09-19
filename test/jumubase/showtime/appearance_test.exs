defmodule Jumubase.AppearanceTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Appearance

  describe "changeset" do
    setup %{} do
      [valid_attrs: valid_appearance_attrs()]
    end

    test "with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = Appearance.changeset(%Appearance{}, valid_attrs)
      assert changeset.valid?
    end

    test "without an associated performance", %{valid_attrs: valid_attrs} do
      attrs = Map.put(valid_attrs, :performance_id, nil)
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end

    test "without a nested participant", %{valid_attrs: valid_attrs} do
      attrs = Map.put(valid_attrs, :participant, nil)
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end

    test "without a participant role", %{valid_attrs: valid_attrs} do
      attrs = Map.put(valid_attrs, :participant_role, nil)
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end

    test "with an invalid participant role", %{valid_attrs: valid_attrs} do
      for invalid_role <- ["solist", "acc", "ensemble"] do
        attrs = Map.put(valid_attrs, :participant_role, invalid_role)
        changeset = Appearance.changeset(%Appearance{}, attrs)
        refute changeset.valid?
      end
    end

    test "without an instrument", %{valid_attrs: valid_attrs} do
      attrs = Map.put(valid_attrs, :instrument, "")
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end
  end
end
