defmodule JumubaseWeb.PageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.PageView

  describe "to_accordion_item/1" do
    test "transforms a host to an accordion item" do
      host = build(:host, id: 123, name: "Name", address: "# Heading\nMore text<br>and then some")

      assert PageView.to_accordion_item(host) == %{
               id: 123,
               title: "Name",
               body: {:safe, "<h1>\nHeading</h1>\n<p>\nMore text<br>and then some</p>\n"}
             }
    end
  end
end
