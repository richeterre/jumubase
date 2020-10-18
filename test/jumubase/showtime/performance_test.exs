defmodule Jumubase.PerformanceTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

  describe "changeset/2" do
    setup %{round: round} do
      [round: round]
    end

    for round <- JumuParams.rounds() do
      @tag round: round
      test "is valid for round #{round} with valid attributes", %{round: round} do
        valid_attrs = valid_performance_attrs(round)
        changeset = Performance.changeset(%Performance{}, valid_attrs, round)
        assert changeset.valid?
      end

      @tag round: round
      test "is invalid for round #{round} without a contest category", %{round: round} do
        valid_attrs = valid_performance_attrs(round)
        params = Map.put(valid_attrs, :contest_category_id, nil)
        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?
      end

      @tag round: round
      test "is invalid for round #{round} without an appearance", %{round: round} do
        valid_attrs = valid_performance_attrs(round)
        params = Map.put(valid_attrs, :appearances, [])
        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?

        assert changeset.errors[:appearances] ==
                 {"The performance must have at least one participant.", []}
      end

      @tag round: round
      test "is invalid for round #{round} with both soloist and ensemblist appearances", %{
        round: round
      } do
        valid_attrs = valid_performance_attrs(round)

        params =
          Map.put(valid_attrs, :appearances, [
            valid_appearance_attrs("soloist"),
            valid_appearance_attrs("ensemblist")
          ])

        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?

        assert changeset.errors[:appearances] ==
                 {"The performance can't have both soloists and ensemblists.", []}
      end

      @tag round: round
      test "is invalid for round #{round} with multiple soloist appearances", %{round: round} do
        valid_attrs = valid_performance_attrs(round)

        params =
          Map.put(valid_attrs, :appearances, [
            valid_appearance_attrs("soloist"),
            valid_appearance_attrs("soloist")
          ])

        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?

        assert changeset.errors[:appearances] ==
                 {"The performance can't have more than one soloist.", []}
      end

      @tag round: round
      test "is invalid for round #{round} with a single ensemblist appearance", %{round: round} do
        valid_attrs = valid_performance_attrs(round)

        params =
          Map.put(valid_attrs, :appearances, [
            valid_appearance_attrs("ensemblist"),
            valid_appearance_attrs("accompanist")
          ])

        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?

        assert changeset.errors[:appearances] ==
                 {"The performance can't have only one ensemblist.", []}
      end

      @tag round: round
      test "is invalid for round #{round} with only accompanist appearances", %{round: round} do
        valid_attrs = valid_performance_attrs(round)

        params =
          Map.put(valid_attrs, :appearances, [
            valid_appearance_attrs("accompanist"),
            valid_appearance_attrs("accompanist")
          ])

        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?

        assert changeset.errors[:appearances] ==
                 {"The performance can't have only accompanists.", []}
      end

      @tag round: round
      test "is invalid for round #{round} without a piece", %{round: round} do
        valid_attrs = valid_performance_attrs(round)
        params = Map.put(valid_attrs, :pieces, [])
        changeset = Performance.changeset(%Performance{}, params, round)
        refute changeset.valid?
        assert changeset.errors[:pieces] == {"The performance must have at least one piece.", []}
      end
    end

    for round <- 0..1 do
      @tag round: round
      test "ignores the given predecessor host for round #{round}", %{round: round} do
        valid_attrs = valid_performance_attrs(round)
        params = Map.put(valid_attrs, :predecessor_host_id, 1)
        changeset = Performance.changeset(%Performance{}, params, round)
        assert get_change(changeset, :predecessor_host_id) == nil
      end
    end

    @tag round: 2
    test "is valid for round 2 with no predecessor host change and existing predecessor data", %{
      round: round
    } do
      performance = %Performance{
        predecessor_host_id: 1,
        predecessor_contest_id: 1,
        predecessor_id: 1
      }

      valid_attrs = valid_performance_attrs(round)
      params = Map.put(valid_attrs, :predecessor_host_id, 1)
      changeset = Performance.changeset(performance, params, round)
      assert changeset.valid?
    end

    @tag round: 2
    test "is invalid for round 2 with a predecessor host change on top of existing predecessor data",
         %{
           round: round
         } do
      performance = %Performance{
        predecessor_host_id: 1,
        predecessor_contest_id: 1,
        predecessor_id: 1
      }

      valid_attrs = valid_performance_attrs(round)
      params = Map.put(valid_attrs, :predecessor_host_id, 2)
      changeset = Performance.changeset(performance, params, round)
      refute changeset.valid?
    end

    @tag round: 2
    test "is valid with a predecessor host change and no existing predecessor data", %{
      round: round
    } do
      performance = %Performance{
        predecessor_host_id: nil,
        predecessor_contest_id: nil,
        predecessor_id: nil
      }

      valid_attrs = valid_performance_attrs(round)
      params = Map.put(valid_attrs, :predecessor_host_id, 1)
      changeset = Performance.changeset(performance, params, round)
      assert changeset.valid?
    end

    @tag round: 2
    test "is invalid with no predecessor host and no existing predecessor data", %{
      round: round
    } do
      performance = %Performance{
        predecessor_host_id: nil,
        predecessor_contest_id: nil,
        predecessor_id: nil
      }

      valid_attrs = valid_performance_attrs(round)
      params = Map.put(valid_attrs, :predecessor_host_id, nil)
      changeset = Performance.changeset(performance, params, round)
      refute changeset.valid?
    end
  end

  describe "stage_changeset/2" do
    @stage_id 1
    @stage_time "2019-01-01T07:00:00Z"

    test "is valid when both stage and stage time change" do
      valid_attrs = %{"stage_id" => @stage_id, "stage_time" => @stage_time}
      changeset = Performance.stage_changeset(%Performance{}, valid_attrs)
      assert changeset.valid?
    end

    test "is valid when stage time is already set and stage changes" do
      attrs = %{"stage_id" => @stage_id}
      changeset = Performance.stage_changeset(%Performance{stage_time: @stage_time}, attrs)
      assert changeset.valid?
    end

    test "is valid when stage is already set and stage time changes" do
      attrs = %{"stage_time" => @stage_time}
      stage = insert(:stage)
      changeset = Performance.stage_changeset(%Performance{stage_id: stage.id}, attrs)
      assert changeset.valid?
    end

    test "is valid when neither stage nor stage time is set" do
      attrs = %{}
      changeset = Performance.stage_changeset(%Performance{}, attrs)
      assert changeset.valid?
    end

    test "is invalid without a stage time when the stage changes" do
      attrs = %{"stage_id" => @stage_id}
      changeset = Performance.stage_changeset(%Performance{}, attrs)
      refute changeset.valid?
    end

    test "is invalid without a stage when the stage time changes" do
      attrs = %{"stage_time" => @stage_time}
      changeset = Performance.stage_changeset(%Performance{}, attrs)
      refute changeset.valid?
    end
  end

  describe "migration_changeset/1" do
    setup do
      c = insert(:contest, round: 1)

      p =
        insert_performance(c,
          age_group: "IV",
          edit_code: "100001",
          appearances: [
            build(:appearance, role: "soloist", points: 23),
            build(:appearance, role: "accompanist", points: 22)
          ],
          pieces: build_list(2, :piece)
        )

      [changeset: Performance.migration_changeset(p), performance: p]
    end

    test "preserves the age group", %{changeset: changeset} do
      assert changeset.changes[:age_group] == "IV"
    end

    test "updates the edit code", %{changeset: changeset} do
      assert changeset.changes[:edit_code] == "200001"
    end

    test "inserts new appearances with empty points", %{changeset: changeset} do
      assert [
               %Changeset{action: :insert, data: %Appearance{points: nil}},
               %Changeset{action: :insert, data: %Appearance{points: nil}}
             ] = changeset.changes[:appearances]
    end

    test "reuses existing appearance participants", %{changeset: changeset, performance: p} do
      # Get existing participant ids
      [%{id: pt1_id}, %{id: pt2_id}] = p.appearances |> Enum.map(& &1.participant)

      assert [
               %Changeset{
                 changes: %{
                   participant: %Changeset{action: :update, data: %Participant{id: ^pt1_id}}
                 }
               },
               %Changeset{
                 changes: %{
                   participant: %Changeset{action: :update, data: %Participant{id: ^pt2_id}}
                 }
               }
             ] = changeset.changes[:appearances]
    end

    test "inserts new pieces", %{changeset: changeset} do
      assert [
               %Changeset{action: :insert, data: %Piece{}},
               %Changeset{action: :insert, data: %Piece{}}
             ] = changeset.changes[:pieces]
    end
  end

  describe "to_edit_code/2" do
    test "generates an edit code string for a Kimu performance" do
      assert Performance.to_edit_code(123, 0) == "000123"
    end

    test "generates an edit code string for an RW performance" do
      assert Performance.to_edit_code(123, 1) == "100123"
    end

    test "generates an edit code string for an LW performance" do
      assert Performance.to_edit_code(123, 2) == "200123"
    end
  end

  describe "non_accompanists/1" do
    test "returns the soloist from a solo performance" do
      sol = build(:appearance, role: "soloist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [sol, acc1, acc2])
      assert Performance.non_accompanists(p) == [sol]
    end

    test "returns the ensemblists from an ensemble performance" do
      [ens1, ens2] = build_list(2, :appearance, role: "ensemblist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [ens1, ens2, acc1, acc2])
      assert Performance.non_accompanists(p) == [ens1, ens2]
    end

    test "sorts ensemblists by insertion date, earliest first" do
      now = Timex.now()
      ens1 = build(:appearance, role: "ensemblist", inserted_at: now)
      ens2 = build(:appearance, role: "ensemblist", inserted_at: Timex.shift(now, seconds: -1))
      p = build(:performance, appearances: [ens1, ens2])
      assert Performance.non_accompanists(p) == [ens2, ens1]
    end
  end

  describe "accompanists/1" do
    test "returns the accompanist(s) from a solo performance" do
      sol = build(:appearance, role: "soloist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [sol, acc1, acc2])
      assert Performance.accompanists(p) == [acc1, acc2]
    end

    test "returns the accompanist(s) from an ensemble performance" do
      [ens1, ens2] = build_list(2, :appearance, role: "ensemblist")
      [acc1, acc2] = build_list(2, :appearance, role: "accompanist")
      p = build(:performance, appearances: [ens1, ens2, acc1, acc2])
      assert Performance.accompanists(p) == [acc1, acc2]
    end

    test "sorts accompanists by insertion date, earliest first" do
      now = Timex.now()
      sol = build(:appearance, role: "soloist")
      acc1 = build(:appearance, role: "accompanist", inserted_at: now)
      acc2 = build(:appearance, role: "accompanist", inserted_at: Timex.shift(now, seconds: -1))
      p = build(:performance, appearances: [sol, acc1, acc2])
      assert Performance.accompanists(p) == [acc2, acc1]
    end
  end

  describe "result_groups/1" do
    test "groups appearances for a soloist-only performance" do
      sol = build(:appearance, role: "soloist")
      cc1 = build(:contest_category, groups_accompanists: false)
      cc2 = build(:contest_category, groups_accompanists: true)

      p1 = build(:performance, contest_category: cc1, appearances: [sol])
      p2 = build(:performance, contest_category: cc2, appearances: [sol])

      assert Performance.result_groups(p1) == [[sol]]
      assert Performance.result_groups(p2) == [[sol]]
    end

    test "groups appearances for an accompanied solo performance with separate accompanists" do
      sol = build(:appearance, role: "soloist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, groups_accompanists: false)
      p = build(:performance, contest_category: cc, appearances: [sol, acc1, acc2])
      assert Performance.result_groups(p) == [[sol], [acc1], [acc2]]
    end

    test "groups appearances for an accompanied solo performance with grouped accompanists" do
      sol = build(:appearance, role: "soloist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, groups_accompanists: true)
      p = build(:performance, contest_category: cc, appearances: [sol, acc1, acc2])
      assert Performance.result_groups(p) == [[sol], [acc1, acc2]]
    end

    test "groups appearances for an ensemblist-only performance" do
      ensemblists = build_list(2, :appearance, role: "ensemblist")
      cc1 = build(:contest_category, groups_accompanists: false)
      cc2 = build(:contest_category, groups_accompanists: true)

      p1 = build(:performance, contest_category: cc1, appearances: ensemblists)
      p2 = build(:performance, contest_category: cc2, appearances: ensemblists)

      assert Performance.result_groups(p1) == [ensemblists]
      assert Performance.result_groups(p2) == [ensemblists]
    end

    test "groups appearances for an accompanied ensemble performance with separate accompanists" do
      ens1 = build(:appearance, role: "ensemblist")
      ens2 = build(:appearance, role: "ensemblist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, groups_accompanists: false)
      p = build(:performance, contest_category: cc, appearances: [ens1, ens2, acc1, acc2])
      assert Performance.result_groups(p) == [[ens1, ens2], [acc1], [acc2]]
    end

    test "groups appearances for an accompanied ensemble performance with grouped accompanists" do
      ens1 = build(:appearance, role: "ensemblist")
      ens2 = build(:appearance, role: "ensemblist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, groups_accompanists: true)
      p = build(:performance, contest_category: cc, appearances: [ens1, ens2, acc1, acc2])
      assert Performance.result_groups(p) == [[ens1, ens2], [acc1, acc2]]
    end
  end

  describe "has_results?/1" do
    test "returns whether the performance contains any appearance with points" do
      p1 =
        build(:performance,
          appearances: [build(:appearance, points: 25), build(:appearance, points: 21)]
        )

      p2 =
        build(:performance,
          appearances: [build(:appearance, points: 25), build(:appearance, points: nil)]
        )

      p3 = build(:performance, appearances: build_list(2, :appearance, points: nil))

      assert Performance.has_results?(p1)
      assert Performance.has_results?(p2)
      refute Performance.has_results?(p3)
    end
  end

  # Private helpers

  defp valid_performance_attrs(round) do
    base_params =
      params_for(:performance, edit_code: nil, age_group: nil)
      |> Map.put(:contest_category_id, 1)
      |> Map.put(:appearances, [valid_appearance_attrs()])
      |> Map.put(:pieces, [params_for(:piece)])

    if round == 2 do
      base_params
      |> Map.put(:predecessor_host_id, 1)
    else
      base_params
    end
  end

  defp valid_appearance_attrs do
    params_for(:appearance)
    |> Map.put(:participant, params_for(:participant))
  end

  defp valid_appearance_attrs(role) do
    params_for(:appearance, role: role)
    |> Map.put(:participant, params_for(:participant))
  end
end
