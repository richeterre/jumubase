defmodule Jumubase.UtilsTest do
  use Jumubase.DataCase
  alias Jumubase.Utils
  alias Jumubase.Foundation.Host

  describe "get_ids/1" do
    test "returns a list of ids for the given structs" do
      structs = [%{id: 1}, %Host{id: 2}, %{id: "3"}]
      assert Utils.get_ids(structs) == [1, 2, "3"]
    end
  end

  describe "mode/1" do
    test "returns a list with the single most common element" do
      assert Utils.mode([1, "a", 2, "b", 2]) == [2]
    end

    test "returns a list with all most common elements" do
      assert Utils.mode([1, "a", 2, "b", 2, "b"]) == [2, "b"]
    end

    test "returns an empty list if no elements are given" do
      assert Utils.mode([]) == []
    end
  end

  describe "parse_bool/1" do
    test "converts a boolean string into a boolean" do
      assert Utils.parse_bool("true") == true
      assert Utils.parse_bool("false") == false
    end

    test "preserves the value when passed a boolean" do
      assert Utils.parse_bool(true) == true
      assert Utils.parse_bool(false) == false
    end
  end
end
