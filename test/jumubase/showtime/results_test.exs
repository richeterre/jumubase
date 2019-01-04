defmodule Jumubase.ResultsTest do
  use Jumubase.DataCase
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.Results

  describe "get_prize" do
    test "returns no prize for a Kimu appearance" do
      for points <- JumuParams.points do
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
end
