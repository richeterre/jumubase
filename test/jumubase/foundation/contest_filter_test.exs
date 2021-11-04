defmodule Jumubase.ContestFilterTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.ContestFilter

  @valid_params %{
    season: 56,
    round: 1,
    grouping: "2",
    search_text: "hel"
  }

  describe "changeset/1" do
    test "returns a changeset from valid params" do
      changeset = ContestFilter.changeset(@valid_params)
      assert changeset.changes == @valid_params
    end

    test "ignores irrelevant params" do
      changeset = ContestFilter.changeset(%{foo: "bar"})
      assert changeset.changes == %{}
    end
  end

  describe "from_params/1" do
    test "creates a filter struct from valid params" do
      assert ContestFilter.from_params(@valid_params) ==
               %ContestFilter{
                 season: 56,
                 round: 1,
                 grouping: "2",
                 search_text: "hel"
               }
    end

    test "sets nil values for missing params" do
      assert ContestFilter.from_params(%{}) ==
               %ContestFilter{
                 season: nil,
                 round: nil,
                 grouping: nil,
                 search_text: nil
               }
    end

    test "ignores irrelevant params" do
      assert ContestFilter.from_params(%{round: 1, foo: "bar"}) ==
               %ContestFilter{
                 season: nil,
                 round: 1,
                 grouping: nil,
                 search_text: nil
               }
    end
  end
end
