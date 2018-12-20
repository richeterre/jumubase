defmodule JumubaseWeb.Internal.PageViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias JumubaseWeb.Internal.PageView

  describe "admin_email/0" do
    test "returns the admin's email address" do
      assert PageView.admin_email() == "admin@localhost"
    end
  end
end
