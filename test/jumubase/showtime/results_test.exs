defmodule Jumubase.ResultsTest do
  use Jumubase.DataCase
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.Performance
  alias Jumubase.Showtime.Results

  describe "get_prize/2" do
    test "returns no prize for a Kimu appearance" do
      for points <- JumuParams.points() do
        assert Results.get_prize(points, 0) == nil
      end
    end

    test "returns the correct prize for a RW appearance" do
      assert Results.get_prize(25, 1) == "1. Preis"
      assert Results.get_prize(21, 1) == "1. Preis"
      assert Results.get_prize(20, 1) == "2. Preis"
      assert Results.get_prize(17, 1) == "2. Preis"
      assert Results.get_prize(16, 1) == "3. Preis"
      assert Results.get_prize(13, 1) == "3. Preis"
      assert Results.get_prize(12, 1) == nil
    end

    test "returns the correct prize for a LW appearance" do
      assert Results.get_prize(25, 2) == "1. Preis"
      assert Results.get_prize(23, 2) == "1. Preis"
      assert Results.get_prize(22, 2) == "2. Preis"
      assert Results.get_prize(20, 2) == "2. Preis"
      assert Results.get_prize(19, 2) == "3. Preis"
      assert Results.get_prize(17, 2) == "3. Preis"
      assert Results.get_prize(16, 2) == nil
    end
  end

  describe "get_rating/2" do
    test "returns the correct rating for a Kimu appearance" do
      assert Results.get_rating(25, 0) == "mit hervorragendem Erfolg teilgenommen"
      assert Results.get_rating(23, 0) == "mit hervorragendem Erfolg teilgenommen"
      assert Results.get_rating(22, 0) == "mit sehr gutem Erfolg teilgenommen"
      assert Results.get_rating(21, 0) == "mit sehr gutem Erfolg teilgenommen"
      assert Results.get_rating(20, 0) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(17, 0) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(16, 0) == "mit Erfolg teilgenommen"
      assert Results.get_rating(9, 0) == "mit Erfolg teilgenommen"
      assert Results.get_rating(8, 0) == "teilgenommen"
      assert Results.get_rating(0, 0) == "teilgenommen"
    end

    test "returns the correct rating for a RW appearance" do
      assert Results.get_rating(25, 1) == nil
      assert Results.get_rating(13, 1) == nil
      assert Results.get_rating(12, 1) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(9, 1) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(8, 1) == "mit Erfolg teilgenommen"
      assert Results.get_rating(5, 1) == "mit Erfolg teilgenommen"
      assert Results.get_rating(4, 1) == "teilgenommen"
      assert Results.get_rating(0, 1) == "teilgenommen"
    end

    test "returns the correct rating for a LW appearance" do
      assert Results.get_rating(25, 2) == nil
      assert Results.get_rating(17, 2) == nil
      assert Results.get_rating(16, 2) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(14, 2) == "mit gutem Erfolg teilgenommen"
      assert Results.get_rating(13, 2) == "mit Erfolg teilgenommen"
      assert Results.get_rating(11, 2) == "mit Erfolg teilgenommen"
      assert Results.get_rating(10, 2) == "teilgenommen"
      assert Results.get_rating(0, 2) == "teilgenommen"
    end
  end

  describe "advances?/1" do
    setup do
      cc =
        insert(:contest_category,
          contest: build(:contest),
          min_advancing_age_group: "III",
          max_advancing_age_group: "IV"
        )

      [contest_category: cc]
    end

    test "returns false for a performance in a non-advancing contest category" do
      cc =
        insert(:contest_category,
          contest: build(:contest),
          min_advancing_age_group: nil,
          max_advancing_age_group: nil
        )

      p = insert_performance(cc, "III", [{"soloist", 23}])
      refute Results.advances?(p)
    end

    test "returns false for a performance with an ineligible age group", %{contest_category: cc} do
      for ag <- ~w(II V) do
        p = insert_performance(cc, ag, [{"soloist", 23}])
        refute Results.advances?(p)
      end
    end

    test "returns false for a performance with insufficient non-acc points", %{
      contest_category: cc
    } do
      p = insert_performance(cc, "III", [{"soloist", 22}, {"accompanist", 23}])
      refute Results.advances?(p)
    end

    test "returns true for a performance with suitable age group and sufficient non-acc points",
         %{contest_category: cc} do
      p = insert_performance(cc, "III", [{"soloist", 23}, {"accompanist", 22}])
      assert Results.advances?(p)
    end

    test "always returns false for accompanist appearances, no matter the soloist result", %{
      contest_category: cc
    } do
      %{appearances: [sol1, acc1]} =
        p = insert_performance(cc, "III", [{"soloist", 22}, {"accompanist", 23}])

      refute Results.advances?(sol1, p)
      refute Results.advances?(acc1, p)

      %{appearances: [sol2, acc2]} =
        p = insert_performance(cc, "III", [{"soloist", 23}, {"accompanist", 23}])

      assert Results.advances?(sol2, p)
      refute Results.advances?(acc2, p)
    end

    test "returns an error when the given appearance and performance don't match", %{
      contest_category: cc
    } do
      %{appearances: [a]} = insert_performance(cc)
      p = insert_performance(cc)
      assert_raise FunctionClauseError, fn -> Results.advances?(a, p) end
    end
  end

  describe "needs_eligibility_check?/3" do
    test "checks advancing RW performance with accompanist group having <23 points" do
      c = insert(:contest, round: 1)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 22}, {"accompanist", 22}])

      for non_acc <- Performance.non_accompanists(p) do
        refute Results.needs_eligibility_check?(non_acc, p, c.round)
      end

      for acc <- Performance.accompanists(p) do
        assert Results.needs_eligibility_check?(acc, p, c.round)
      end
    end

    test "checks advancing RW performance with accompanist group having 23+ points" do
      c = insert(:contest, round: 1)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 23}, {"accompanist", 23}])

      for a <- p.appearances, do: refute(Results.needs_eligibility_check?(a, p, c.round))
    end

    test "checks advancing RW performance with single accompanist having <23 points" do
      c = insert(:contest, round: 1)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 22}])

      for a <- p.appearances, do: refute(Results.needs_eligibility_check?(a, p, c.round))
    end

    test "checks non-advancing RW performance with accompanist group" do
      c = insert(:contest, round: 1)
      p = do_insert_performance(c, [{"soloist", 22}, {"accompanist", 22}, {"accompanist", 22}])

      for a <- p.appearances, do: refute(Results.needs_eligibility_check?(a, p, c.round))
    end

    test "checks advancing LW performance with accompanist group having <23 points" do
      c = insert(:contest, round: 2)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 22}, {"accompanist", 22}])

      for non_acc <- Performance.non_accompanists(p) do
        refute Results.needs_eligibility_check?(non_acc, p, c.round)
      end

      for acc <- Performance.accompanists(p) do
        assert Results.needs_eligibility_check?(acc, p, c.round)
      end
    end

    test "checks advancing LW performance with accompanist group having 23+ points" do
      c = insert(:contest, round: 2)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 23}, {"accompanist", 23}])

      for non_acc <- Performance.non_accompanists(p) do
        refute Results.needs_eligibility_check?(non_acc, p, c.round)
      end

      for acc <- Performance.accompanists(p) do
        assert Results.needs_eligibility_check?(acc, p, c.round)
      end
    end

    test "checks advancing LW performance with single accompanist having <23 points" do
      c = insert(:contest, round: 2)
      p = do_insert_performance(c, [{"soloist", 23}, {"accompanist", 22}])

      for a <- p.appearances, do: refute(Results.needs_eligibility_check?(a, p, c.round))
    end

    test "checks non-advancing LW performance with accompanist group" do
      c = insert(:contest, round: 2)
      p = do_insert_performance(c, [{"soloist", 22}, {"accompanist", 22}, {"accompanist", 22}])

      for a <- p.appearances, do: refute(Results.needs_eligibility_check?(a, p, c.round))
    end
  end

  # Private helpers

  defp do_insert_performance(c, appearance_shorthands) do
    insert_performance(c,
      appearances:
        Enum.map(appearance_shorthands, fn {role, points} ->
          build(:appearance, role: role, points: points)
        end)
    )
  end

  defp insert_performance(cc, age_group, appearance_shorthands) do
    insert_performance(cc,
      age_group: age_group,
      appearances:
        Enum.map(appearance_shorthands, fn {role, points} ->
          build(:appearance, role: role, points: points)
        end)
    )
  end
end
