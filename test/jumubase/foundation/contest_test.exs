defmodule Jumubase.ContestTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.Contest

  describe "changeset" do
    test "with valid attributes" do
      params = params_with_assocs(:contest)
      changeset = Contest.changeset(%Contest{}, params)
      assert changeset.valid?
    end

    test "without a season" do
      params = params_with_assocs(:contest, season: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "with an invalid season" do
      for season <- [-1, 0] do
        params = params_with_assocs(:contest, season: season)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "without a round" do
      params = params_with_assocs(:contest, round: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "with an invalid round" do
      for round <- [-1, 0, 3] do
        params = params_with_assocs(:contest, round: round)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end

    test "without a start date" do
      params = params_with_assocs(:contest, start_date: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "without an end date" do
      params = params_with_assocs(:contest, end_date: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "with an end date before the start date" do
      %{start_date: start_date} = params_with_assocs(:contest)
      params = params_with_assocs(:contest, end_date: Timex.shift(start_date, days: -1))
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "without a deadline" do
      params = params_with_assocs(:contest, deadline: nil)
      changeset = Contest.changeset(%Contest{}, params)
      refute changeset.valid?
    end

    test "with a deadline not before the start date" do
      %{start_date: start_date} = params_with_assocs(:contest)
      for deadline <- [start_date, Timex.shift(start_date, days: 1)] do
        params = params_with_assocs(:contest, deadline: deadline)
        changeset = Contest.changeset(%Contest{}, params)
        refute changeset.valid?
      end
    end
  end
end
