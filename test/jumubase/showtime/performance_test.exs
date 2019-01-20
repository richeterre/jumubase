defmodule Jumubase.PerformanceTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Performance

  describe "changeset" do
    setup do
      c = insert(:contest) |> with_contest_categories
      [cc, _] = c.contest_categories
      [valid_attrs: valid_performance_attrs(cc)]
    end

    test "with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = Performance.changeset(%Performance{}, valid_attrs)
      assert changeset.valid?
    end

    test "without an associated contest category", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :contest_category_id, nil)
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
    end

    test "without an appearance", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance must have at least one participant.", []}
    end

    test "with both soloist and ensemblist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("soloist"),
        valid_appearance_attrs("ensemblist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have both soloists and ensemblists.", []}
    end

    test "with multiple soloist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("soloist"),
        valid_appearance_attrs("soloist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have more than one soloist.", []}
    end

    test "with a single ensemblist appearance", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("ensemblist"),
        valid_appearance_attrs("accompanist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have only one ensemblist.", []}
    end

    test "with only accompanist appearances", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :appearances, [
        valid_appearance_attrs("accompanist"),
        valid_appearance_attrs("accompanist"),
      ])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance can't have only accompanists.", []}
    end

    test "without a piece", %{valid_attrs: valid_attrs} do
      params = Map.put(valid_attrs, :pieces, [])
      changeset = Performance.changeset(%Performance{}, params)
      refute changeset.valid?
      assert changeset.errors[:base] == {"The performance must have at least one piece.", []}
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
      now = Timex.now
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
      now = Timex.now
      sol = build(:appearance, role: "soloist")
      acc1 = build(:appearance, role: "accompanist", inserted_at: now)
      acc2 = build(:appearance, role: "accompanist", inserted_at: Timex.shift(now, seconds: -1))
      p = build(:performance, appearances: [sol, acc1, acc2])
      assert Performance.accompanists(p) == [acc2, acc1]
    end
  end

  describe "result_groups/1" do
    test "groups appearances for a classical or Kimu solo performance without accompanists" do
      for genre <- ["classical", "kimu"] do
        sol = build(:appearance, role: "soloist")
        cc = build(:contest_category, category: build(:category, genre: genre))
        p = build(:performance, contest_category: cc, appearances: [sol])
        assert Performance.result_groups(p) == [[sol]]
      end
    end

    test "groups appearances for a classical or Kimu solo performance with accompanists" do
      for genre <- ["classical", "kimu"] do
        sol = build(:appearance, role: "soloist")
        acc1 = build(:appearance, role: "accompanist")
        acc2 = build(:appearance, role: "accompanist")
        cc = build(:contest_category, category: build(:category, genre: genre))
        p = build(:performance, contest_category: cc, appearances: [sol, acc1, acc2])
        assert Performance.result_groups(p) == [[sol], [acc1], [acc2]]
      end
    end

    test "groups appearances for a classical or Kimu ensemble performance" do
      for genre <- ["classical", "kimu"] do
        appearances = build_list(2, :appearance, role: "ensemblist")
        cc = build(:contest_category, category: build(:category, genre: genre))
        p = build(:performance, contest_category: cc, appearances: appearances)
        assert Performance.result_groups(p) == [appearances]
      end
    end

    test "groups appearances for a popular solo performance without accompanists" do
      sol = build(:appearance, role: "soloist")
      cc = build(:contest_category, category: build(:category, genre: "popular"))
      p = build(:performance, contest_category: cc, appearances: [sol])
      assert Performance.result_groups(p) == [[sol]]
    end

    test "groups appearances for a popular solo performance with accompanists" do
      sol = build(:appearance, role: "soloist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, category: build(:category, genre: "popular"))
      p = build(:performance, contest_category: cc, appearances: [sol, acc1, acc2])
      assert Performance.result_groups(p) == [[sol], [acc1, acc2]]
    end

    test "groups appearances for a popular ensemble performance without accompanists" do
      appearances = build_list(2, :appearance, role: "ensemblist")
      cc = build(:contest_category, category: build(:category, genre: "popular"))
      p = build(:performance, contest_category: cc, appearances: appearances)
      assert Performance.result_groups(p) == [appearances]
    end

    test "groups appearances for a popular ensemble performance with accompanists" do
      ens1 = build(:appearance, role: "ensemblist")
      ens2 = build(:appearance, role: "ensemblist")
      acc1 = build(:appearance, role: "accompanist")
      acc2 = build(:appearance, role: "accompanist")
      cc = build(:contest_category, category: build(:category, genre: "popular"))
      p = build(:performance, contest_category: cc, appearances: [ens1, ens2, acc1, acc2])
      assert Performance.result_groups(p) == [[ens1, ens2], [acc1, acc2]]
    end
  end

  # Private helpers

  defp valid_performance_attrs(contest_category) do
    params_for(:performance, edit_code: nil, age_group: nil)
    |> Map.put(:contest_category_id, contest_category.id)
    |> Map.put(:appearances, [valid_appearance_attrs()])
    |> Map.put(:pieces, [params_for(:piece)])
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
