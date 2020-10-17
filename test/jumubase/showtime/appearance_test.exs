defmodule Jumubase.AppearanceTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
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

      changeset =
        Appearance.changeset(a, %{
          participant: %{
            id: a.participant.id,
            given_name: "X",
            family_name: "X",
            birthdate: ~D[2001-02-03]
          }
        })

      refute changeset.valid?

      assert changeset.errors == [
               participant:
                 {"To change the name or birthdate, please remove and add back this person.", ''}
             ]
    end

    test "allows non-identity changes when updating a nested participant" do
      %{appearances: [a]} = insert(:contest) |> insert_performance

      changeset =
        Appearance.changeset(a, %{
          participant: %{
            id: a.participant.id,
            phone: "456",
            email: "new@example.org"
          }
        })

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

  describe "migration_changeset/1" do
    setup do
      c = insert(:contest)
      a = insert_appearance(c)
      [changeset: Appearance.migration_changeset(a), appearance: a]
    end

    test "preserves the instrument, role and age group", %{changeset: cs, appearance: a} do
      assert cs.data.instrument == a.instrument
      assert cs.data.role == a.role
      assert cs.data.age_group == a.age_group
    end

    test "clears the points", %{changeset: changeset} do
      assert %Changeset{action: nil, data: %Appearance{points: nil}} = changeset
    end

    test "preserves the associated participant", %{changeset: cs, appearance: a} do
      pt = a.participant
      assert %Changeset{changes: %{participant: %Changeset{action: :update, data: ^pt}}} = cs
    end
  end

  test "soloist?/1 returns whether the appearance has a soloist role" do
    assert Appearance.soloist?(build(:appearance, role: "soloist"))
    refute Appearance.soloist?(build(:appearance, role: "ensemblist"))
    refute Appearance.soloist?(build(:appearance, role: "accompanist"))
  end

  test "ensemblist?/1 returns whether the appearance has an ensemblist role" do
    assert Appearance.ensemblist?(build(:appearance, role: "ensemblist"))
    refute Appearance.ensemblist?(build(:appearance, role: "soloist"))
    refute Appearance.ensemblist?(build(:appearance, role: "accompanist"))
  end

  test "accompanist?/1 returns whether the appearance has an accompanist role" do
    assert Appearance.accompanist?(build(:appearance, role: "accompanist"))
    refute Appearance.accompanist?(build(:appearance, role: "soloist"))
    refute Appearance.accompanist?(build(:appearance, role: "ensemblist"))
  end

  test "has_points?/1 returns whether the appearance has points" do
    assert Appearance.has_points?(build(:appearance, points: 25))
    refute Appearance.has_points?(build(:appearance, points: nil))
  end
end
