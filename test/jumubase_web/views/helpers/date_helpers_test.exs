defmodule JumubaseWeb.DateHelpersTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.DateHelpers

  setup do
    [
      date: ~D[2000-01-02],
      time: ~T[23:34:45],
      datetime: ~N[2000-01-02T23:34:45]
    ]
  end

  describe "to_naive_datetime/2" do
    test "combines a date and time to a timezone-less datetime", %{date: date, time: time} do
      result = DateHelpers.to_naive_datetime(date, time)
      assert NaiveDateTime.to_iso8601(result) == "2000-01-02T23:34:45"
    end
  end

  describe "format_date/1" do
    test "formats a date for display to the user", %{date: date} do
      assert DateHelpers.format_date(date) == "2 January 2000"
    end

    test "returns nil if nil is passed for the date" do
      assert DateHelpers.format_date(nil) == nil
    end
  end

  describe "format_date/2" do
    test "formats a date in full style", %{date: date} do
      assert DateHelpers.format_date(date, :full) == "2 January 2000"
    end

    test "formats a date in medium style", %{date: date} do
      assert DateHelpers.format_date(date, :medium) == "2 January"
    end

    test "returns nil if nil is passed for the date" do
      assert DateHelpers.format_date(nil, :full) == nil
    end
  end

  describe "format_datetime/1" do
    test "formats a datetime for display to the user", %{datetime: dt} do
      assert DateHelpers.format_datetime(dt) == "2 January 2000, 23:34"
    end

    test "returns nil if nil is passed for the datetime" do
      assert DateHelpers.format_datetime(nil) == nil
    end
  end

  describe "format_datetime/2" do
    test "formats a datetime in full style", %{datetime: dt} do
      assert DateHelpers.format_datetime(dt, :full) == "2 January 2000, 23:34"
    end

    test "formats a datetime in medium style", %{datetime: dt} do
      assert DateHelpers.format_datetime(dt, :medium) == "2 January, 23:34"
    end

    test "formats a datetime in time-only style", %{datetime: dt} do
      assert DateHelpers.format_datetime(dt, :time) == "23:34"
    end

    test "returns nil if nil is passed for the datetime" do
      assert DateHelpers.format_datetime(nil, :full) == nil
    end
  end
end
