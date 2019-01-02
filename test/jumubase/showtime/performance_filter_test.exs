defmodule Jumubase.PerformanceFilterTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.PerformanceFilter

  @valid_params %{
    stage_date: ~D[2019-01-01],
    stage_id: 1,
    genre: "kimu",
    contest_category_id: 2,
    age_group: "Ia",
    results_public: true,
  }

  describe "changeset/1" do
    test "returns a changeset from valid params" do
      changeset = PerformanceFilter.changeset(@valid_params)
      assert changeset.changes == @valid_params
    end

    test "ignores irrelevant params" do
      changeset = PerformanceFilter.changeset(%{foo: "bar"})
      assert changeset.changes == %{}
    end
  end

  describe "from_params/1" do
    test "creates a filter struct from valid params" do
      assert PerformanceFilter.from_params(@valid_params) ==
        %PerformanceFilter{
          stage_date: ~D[2019-01-01],
          stage_id: 1,
          genre: "kimu",
          contest_category_id: 2,
          age_group: "Ia",
          results_public: true,
        }
    end

    test "sets nil values for missing params" do
      assert PerformanceFilter.from_params(%{}) ==
        %PerformanceFilter{
          stage_date: nil,
          stage_id: nil,
          genre: nil,
          contest_category_id: nil,
          age_group: nil,
          results_public: nil
        }
    end

    test "ignores irrelevant params" do
      assert PerformanceFilter.from_params(%{age_group: "Ia", foo: "bar"}) ==
        %PerformanceFilter{
          stage_date: nil,
          stage_id: nil,
          genre: nil,
          contest_category_id: nil,
          age_group: "Ia",
          results_public: nil,
        }
    end
  end

  describe "active?/1" do
    test "returns true when any filter value is set" do
      for {key, value} <- @valid_params do
        filter = PerformanceFilter.from_params(Map.put(%{}, key, value))
        assert PerformanceFilter.active?(filter)
      end
    end

    test "returns false when no filter values are set" do
      filter = PerformanceFilter.from_params(%{})
      refute PerformanceFilter.active?(filter)
    end
  end
end
