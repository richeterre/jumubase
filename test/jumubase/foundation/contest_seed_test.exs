defmodule Jumubase.ContestSeedTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.ContestSeed

  describe "changeset" do
    test "is valid with valid attributes" do
      params = valid_params()
      changeset = ContestSeed.changeset(%ContestSeed{}, params)

      assert changeset.valid?
    end

    test "is invalid without a season" do
      params = %{valid_params() | season: nil}
      changeset = ContestSeed.changeset(%ContestSeed{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid season" do
      for season <- [-1, 0] do
        params = %{valid_params() | season: season}
        changeset = ContestSeed.changeset(%ContestSeed{}, params)
        refute changeset.valid?
      end
    end

    test "is invalid without a round" do
      params = %{valid_params() | round: nil}
      changeset = ContestSeed.changeset(%ContestSeed{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid round" do
      for round <- [-1, 3] do
        params = %{valid_params() | round: round}
        changeset = ContestSeed.changeset(%ContestSeed{}, params)
        refute changeset.valid?
      end
    end

    test "is valid with a valid round" do
      for round <- [0, 1, 2] do
        params = %{valid_params() | round: round}
        changeset = ContestSeed.changeset(%ContestSeed{}, params)
        assert changeset.valid?
      end
    end

    test "is invalid without contest categories" do
      params = %{valid_params() | contest_categories: []}
      changeset = ContestSeed.changeset(%ContestSeed{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid contest category" do
      invalid_cc_params = %{valid_contest_category_params() | category_id: nil}
      params = %{valid_params() | contest_categories: [invalid_cc_params]}

      changeset = ContestSeed.changeset(%ContestSeed{}, params)

      refute changeset.valid?
    end

    # Private helpers

    defp valid_params do
      %{season: 56, round: 1, contest_categories: [valid_contest_category_params()]}
    end
  end
end
