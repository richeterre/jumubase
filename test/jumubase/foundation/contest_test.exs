defmodule Jumubase.ContestTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.Contest

  describe "changeset" do
    test "is valid with valid attributes" do
      params = params_with_assocs(:contest)
      changeset = Contest.changeset(%Contest{}, params)
      assert changeset.valid?
    end

    test "is invalid without a season" do
      params = params_with_assocs(:contest, season: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid season" do
      for season <- [-1, 0] do
        params = params_with_assocs(:contest, season: season)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "is invalid without a round" do
      params = params_with_assocs(:contest, round: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid round" do
      for round <- [-1, 3] do
        params = params_with_assocs(:contest, round: round)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "is valid with a valid round" do
      for round <- [0, 1, 2] do
        params = params_with_assocs(:contest, round: round)
        changeset = Contest.changeset(%Contest{}, params)
        assert changeset.valid?
      end
    end

    test "is invalid without a grouping" do
      params = params_with_assocs(:contest, grouping: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid grouping" do
      for grouping <- [1, "0", "A"] do
        params = params_with_assocs(:contest, grouping: grouping)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "is valid with a valid grouping" do
      for grouping <- ~w(1 2 3) do
        params = params_with_assocs(:contest, grouping: grouping)
        changeset = Contest.changeset(%Contest{}, params)
        assert changeset.valid?
      end
    end

    test "is invalid without a start date" do
      params = params_with_assocs(:contest, start_date: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid without an end date" do
      params = params_with_assocs(:contest, end_date: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid with an end date before the start date" do
      %{start_date: start_date} = params_with_assocs(:contest)
      params = params_with_assocs(:contest, end_date: Timex.shift(start_date, days: -1))
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid without a deadline" do
      params = params_with_assocs(:contest, deadline: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "is invalid with a deadline not before the start date" do
      %{start_date: start_date} = params_with_assocs(:contest)

      for deadline <- [start_date, Timex.shift(start_date, days: 1)] do
        params = params_with_assocs(:contest, deadline: deadline)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "is valid without a certificate date" do
      params = params_with_assocs(:contest, certificate_date: nil)
      changeset = Contest.changeset(%Contest{}, params)
      assert changeset.valid?
    end

    test "is invalid with a certificate date before the end date" do
      %{end_date: end_date} = params_with_assocs(:contest)
      certificate_date = Timex.shift(end_date, days: -1)
      params = params_with_assocs(:contest, certificate_date: certificate_date)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end
  end

  describe "deadline_passed?/2" do
    test "returns whether the contest deadline has passed on the given date" do
      deadline = Timex.today()
      c = build(:contest, deadline: deadline)

      refute Contest.deadline_passed?(c, deadline |> Timex.shift(days: -1))
      refute Contest.deadline_passed?(c, deadline)
      assert Contest.deadline_passed?(c, deadline |> Timex.shift(days: 1))
    end
  end
end
