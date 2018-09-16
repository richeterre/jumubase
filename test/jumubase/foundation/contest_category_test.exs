defmodule Jumubase.ContestCategoryTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.ContestCategory

  @invalid_ags ["", "ii", "Ic", "VIII"]

  describe "changeset" do
    test "with valid attributes" do
      params = params_with_assocs(:contest_category)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      assert changeset.valid?
    end

    test "without an associated contest" do
      params = params_with_assocs(:contest_category, contest: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "without an associated category" do
      params = params_with_assocs(:contest_category, category: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "without a minimum age group" do
      params = params_with_assocs(:contest_category, min_age_group: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "with an invalid minimum age group" do
      for invalid_ag <- @invalid_ags do
        params = params_with_assocs(:contest_category, min_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "without a maximum age group" do
      params = params_with_assocs(:contest_category, max_age_group: nil)
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "with an invalid maximum age group" do
      for invalid_ag <- @invalid_ags do
        params = params_with_assocs(:contest_category, max_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "with an invalid minimum advancing age group" do
      for invalid_ag <- @invalid_ags do
        params = params_with_assocs(:contest_category, min_advancing_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "with an invalid maximum advancing age group" do
      for invalid_ag <- @invalid_ags do
        params = params_with_assocs(:contest_category, max_advancing_age_group: invalid_ag)
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end
  end
end
