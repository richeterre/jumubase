defmodule Jumubase.UtilsTest do
  use Jumubase.DataCase
  alias Jumubase.Utils
  alias Jumubase.Foundation.Host

  doctest Utils

  describe "get_ids/1" do
    test "returns a list of ids for the given structs" do
      structs = [%{id: 1}, %Host{id: 2}, %{id: "3"}]
      assert Utils.get_ids(structs) == [1, 2, "3"]
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
