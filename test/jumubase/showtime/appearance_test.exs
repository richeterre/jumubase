defmodule Jumubase.AppearanceTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Appearance

  describe "changeset" do
    setup do
      attrs =
        params_for(:appearance)
        |> Map.put(:participant, params_for(:participant))

      [valid_attrs: attrs]
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
      attrs = Map.put(valid_attrs, :role, nil)
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end

    test "with an invalid participant role", %{valid_attrs: valid_attrs} do
      for invalid_role <- ["solist", "acc", "ensemble"] do
        attrs = Map.put(valid_attrs, :role, invalid_role)
        changeset = Appearance.changeset(%Appearance{}, attrs)
        refute changeset.valid?
      end
    end

    test "without an instrument", %{valid_attrs: valid_attrs} do
      attrs = Map.put(valid_attrs, :instrument, "")
      changeset = Appearance.changeset(%Appearance{}, attrs)
      refute changeset.valid?
    end

    test "prevents name or birthdate changes when updating a nested participant" do
      %{appearances: [a]} = insert(:contest) |> insert_performance

      changeset = Appearance.changeset(a, %{participant: %{
        id: a.participant.id,
        given_name: "X",
        family_name: "X",
        birthdate: ~D[2001-02-03],
      }})

      refute changeset.valid?
      assert changeset.changes[:participant].errors == [
        birthdate: {"can't be changed", []},
        family_name: {"can't be changed", []},
        given_name: {"can't be changed", []},
      ]
    end

    test "allows non-identity changes when updating a nested participant" do
      %{appearances: [a]} = insert(:contest) |> insert_performance

      changeset = Appearance.changeset(a, %{participant: %{
        id: a.participant.id,
        phone: "456",
        email: "new@example.org",
      }})

      assert changeset.valid?
    end
  end

  describe "result_changeset/2" do
    test "is valid with valid points" do
      for valid_points <- [0, 20, 25] do
        changeset = Appearance.result_changeset(%Appearance{}, valid_points)
        assert changeset.valid?
      end
    end

    test "is invalid with invalid points" do
      for invalid_points <- [-1, 20.9, 26] do
        changeset = Appearance.result_changeset(%Appearance{}, invalid_points)
        refute changeset.valid?
      end
    end

    test "casts points given as string to integer" do
      changeset = Appearance.result_changeset(%Appearance{}, "25")
      assert changeset.changes.points == 25
    end

    test "discards empty point string" do
      changeset = Appearance.result_changeset(%Appearance{}, "")
      refute Map.has_key?(changeset.changes, :points)
    end
  end

  test "is_soloist/1 returns whether the appearance has a soloist role" do
    assert Appearance.is_soloist(build(:appearance, role: "soloist"))
    refute Appearance.is_soloist(build(:appearance, role: "ensemblist"))
    refute Appearance.is_soloist(build(:appearance, role: "accompanist"))
  end

  test "is_ensemblist/1 returns whether the appearance has an ensemblist role" do
    assert Appearance.is_ensemblist(build(:appearance, role: "ensemblist"))
    refute Appearance.is_ensemblist(build(:appearance, role: "soloist"))
    refute Appearance.is_ensemblist(build(:appearance, role: "accompanist"))
  end

  test "is_accompanist/1 returns whether the appearance has an accompanist role" do
    assert Appearance.is_accompanist(build(:appearance, role: "accompanist"))
    refute Appearance.is_accompanist(build(:appearance, role: "soloist"))
    refute Appearance.is_accompanist(build(:appearance, role: "ensemblist"))
  end
end
