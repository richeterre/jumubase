defmodule Jumubase.InstrumentsTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Instruments

  test "all/0 returns a list of all instruments" do
    %{} = result = Instruments.all
    assert result |> Enum.count == 10
  end

  test "name/1 returns an instrument's display name, if found" do
    assert Instruments.name("piano") == "Piano"
  end

  test "name/1 returns nil if the instrument isn't found" do
    assert Instruments.name("foobar") == nil
  end
end
