defmodule JumubaseWeb.DateHelpersTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.DateHelpers

  describe "to_utc_datetime/2" do
    test "combines a date and time to a UTC datetime" do
      result = DateHelpers.to_utc_datetime(~D[2000-01-02], ~T[03:40:50])
      assert DateTime.to_iso8601(result) == "2000-01-02T03:40:50Z"
    end
  end

  describe "format_date/1" do
    test "formats a date for display to the user" do
      assert DateHelpers.format_date(~D[2018-12-15]) == "15 December 2018"
    end

    test "returns nil if nil is passed for the date" do
      assert DateHelpers.format_date(nil) == nil
    end
  end

  describe "format_date/2" do
    test "formats a date in full style" do
      assert DateHelpers.format_date(~D[2018-12-15], :full) == "15 December 2018"
    end

    test "formats a date in medium style" do
      assert DateHelpers.format_date(~D[2018-12-15], :medium) == "15 December"
    end

    test "returns nil if nil is passed for the date" do
      assert DateHelpers.format_date(nil, :full) == nil
    end
  end
end
