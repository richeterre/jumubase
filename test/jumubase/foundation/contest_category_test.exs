defmodule Jumubase.ContestCategoryTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.ContestCategory

  describe "changeset" do
    test "is valid with valid attributes" do
      params = valid_contest_category_params()
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      assert changeset.valid?
    end

    test "is invalid without a minimum age group" do
      params = %{valid_contest_category_params() | min_age_group: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "is invalid without a maximum age group" do
      params = %{valid_contest_category_params() | max_age_group: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "is valid without a minimum advancing age group" do
      params = %{valid_contest_category_params() | min_advancing_age_group: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      assert changeset.valid?
    end

    test "is valid without a maximum advancing age group" do
      params = %{valid_contest_category_params() | max_advancing_age_group: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      assert changeset.valid?
    end

    test "is invalid with an invalid age group value" do
      for field_name <- [
            :min_age_group,
            :max_age_group,
            :min_advancing_age_group,
            :max_advancing_age_group
          ] do
        params = valid_contest_category_params() |> Map.put(field_name, "invalid")
        changeset = ContestCategory.changeset(%ContestCategory{}, params)
        refute changeset.valid?
      end
    end

    test "is invalid without an 'allows WESPE nominations' flag" do
      params = %{valid_contest_category_params() | allows_wespe_nominations: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end

    test "is invalid without a 'groups accompanists' flag" do
      params = %{valid_contest_category_params() | groups_accompanists: nil}
      changeset = ContestCategory.changeset(%ContestCategory{}, params)
      refute changeset.valid?
    end
  end
end
