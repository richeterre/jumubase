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

  test "is_soloist/1 returns whether the appearance has a soloist role" do
    assert Appearance.is_soloist(build(:appearance, participant_role: "soloist"))
    refute Appearance.is_soloist(build(:appearance, participant_role: "ensemblist"))
    refute Appearance.is_soloist(build(:appearance, participant_role: "accompanist"))
  end

  test "is_ensemblist/1 returns whether the appearance has an ensemblist role" do
    assert Appearance.is_ensemblist(build(:appearance, participant_role: "ensemblist"))
    refute Appearance.is_ensemblist(build(:appearance, participant_role: "soloist"))
    refute Appearance.is_ensemblist(build(:appearance, participant_role: "accompanist"))
  end

  test "is_accompanist/1 returns whether the appearance has an accompanist role" do
    assert Appearance.is_accompanist(build(:appearance, participant_role: "accompanist"))
    refute Appearance.is_accompanist(build(:appearance, participant_role: "soloist"))
    refute Appearance.is_accompanist(build(:appearance, participant_role: "ensemblist"))
  end
end
