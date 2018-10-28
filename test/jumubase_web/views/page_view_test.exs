defmodule JumubaseWeb.PageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.PageView

  describe "render_markdown/1" do
    test "renders nothing when receiving nil as input" do
      assert PageView.render_markdown(nil) == nil
    end

    test "renders Markdown as raw HTML" do
      assert PageView.render_markdown(
        "# Heading\nSome *bold*, <br>broken text"
      ) == {:safe, "<h1>Heading</h1>\n<p>Some <em>bold</em>, <br>broken text</p>\n"}
    end
  end
end
