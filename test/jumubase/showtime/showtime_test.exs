defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance

  describe "performances" do
    test "create_performance/1 creates a new performance" do
      attrs = valid_performance_attrs()

      assert {:ok, %Performance{} = performance} = Showtime.create_performance(attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, performance.edit_code)
    end

    test "change_performance/1 returns a performance changeset" do
      performance = insert(:performance)
      assert %Ecto.Changeset{} = Showtime.change_performance(performance)
    end
  end
end
