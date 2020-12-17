defmodule Jumubase.AgeGroupCalculatorTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Showtime.AgeGroupCalculator

  @season 56

  setup do
    [contest: insert(:contest, season: @season) |> with_contest_categories]
  end

  describe "fix_age_groups/1" do
    test "returns a changeset for a stale performance with separate accompanists", %{contest: c} do
      p =
        insert_performance(c,
          age_group: "III",
          appearances: [
            # Soloist: Their AG should be II, so it needs fixing
            build(:appearance,
              role: "soloist",
              age_group: "III",
              participant: build(:participant, birthdate: ~D[2007-01-01])
            ),
            # Accompanist 1: Their AG should be IV, so it needs fixing
            build(:appearance,
              role: "accompanist",
              age_group: "V",
              participant: build(:participant, birthdate: ~D[2003-01-01])
            ),
            # Accompanist 2: Their AG is already correct
            build(:appearance,
              role: "accompanist",
              age_group: "V",
              participant: build(:participant, birthdate: ~D[2002-12-31])
            )
          ]
        )

      assert %Changeset{
               changes: %{
                 age_group: "II",
                 appearances: [
                   %Changeset{action: :update, changes: %{age_group: "II"}},
                   %Changeset{action: :update, changes: %{age_group: "IV"}},
                   %Changeset{action: :update, changes: %{}}
                 ]
               }
             } = AgeGroupCalculator.fix_age_groups(p, c.season, false)
    end

    test "returns a changeset for a stale performance with grouped accompanists", %{contest: c} do
      p =
        insert_performance(c,
          age_group: "III",
          appearances: [
            # Ensemblists: Their joint AG should be II, so only one already has the correct one
            build(:appearance,
              role: "ensemblist",
              age_group: "III",
              participant: build(:participant, birthdate: ~D[2007-01-02])
            ),
            build(:appearance,
              role: "ensemblist",
              age_group: "II",
              participant: build(:participant, birthdate: ~D[2007-01-01])
            ),
            build(:appearance,
              role: "ensemblist",
              age_group: "III",
              participant: build(:participant, birthdate: ~D[2006-12-31])
            ),
            # Accompanists: Their joint AG should be IV, so only one already has the correct one
            build(:appearance,
              role: "accompanist",
              age_group: "V",
              participant: build(:participant, birthdate: ~D[2003-01-02])
            ),
            build(:appearance,
              role: "accompanist",
              age_group: "IV",
              participant: build(:participant, birthdate: ~D[2003-01-01])
            ),
            build(:appearance,
              role: "accompanist",
              age_group: "V",
              participant: build(:participant, birthdate: ~D[2002-12-31])
            )
          ]
        )

      assert %Changeset{
               changes: %{
                 age_group: "II",
                 appearances: [
                   # Ensemblists:
                   %Changeset{action: :update, changes: %{age_group: "II"}},
                   %Changeset{action: :update, changes: %{}},
                   %Changeset{action: :update, changes: %{age_group: "II"}},
                   # Accompanists:
                   %Changeset{action: :update, changes: %{age_group: "IV"}},
                   %Changeset{action: :update, changes: %{}},
                   %Changeset{action: :update, changes: %{age_group: "IV"}}
                 ]
               }
             } = AgeGroupCalculator.fix_age_groups(p, c.season, true)
    end

    test "returns an empty changeset for a non-stale performance", %{contest: c} do
      p =
        insert_performance(c,
          age_group: "II",
          appearances: [
            build(:appearance,
              role: "soloist",
              age_group: "II",
              participant: build(:participant, birthdate: ~D[2007-01-01])
            ),
            build(:appearance,
              role: "accompanist",
              age_group: "IV",
              participant: build(:participant, birthdate: ~D[2003-01-01])
            )
          ]
        )

      assert %Changeset{changes: %{}} = AgeGroupCalculator.fix_age_groups(p, c.season, false)
    end
  end
end
