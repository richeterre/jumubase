defmodule JumubaseWeb.AppearanceViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.AppearanceView

  test "instrument_name/1 returns an instrument's display name" do
    assert AppearanceView.instrument_name("piano") == "Piano"
  end
end
