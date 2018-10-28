defmodule JumubaseWeb.EmailTest do
  use JumubaseWeb.ConnCase

  describe "registration_success/1" do
    setup do
      [contest: insert(:contest) |> with_contest_categories]
    end

    test "composes an email to confirm the registration", %{contest: c} do
      [cc, _] = c.contest_categories
      performance = insert_performance(cc, appearances: [
        build(:appearance, participant: build(:participant, email: "pt@example.org")),
      ])
      cat_name = cc.category.name

      email = JumubaseWeb.Email.registration_success(performance)

      assert email.to == "pt@example.org"
      assert email.subject == "Your Jumu registration for category \"#{cat_name}\""
      assert email.html_body =~ cat_name
      assert email.html_body =~ performance.edit_code
      assert email.html_body =~ page_url(JumubaseWeb.Endpoint, :edit_registration)
    end

    test "addresses the email to all participants", %{contest: c} do
      [cc, _] = c.contest_categories
      performance = insert_performance(cc, appearances: [
        build(:appearance, participant: build(:participant, email: "pt1@example.org")),
        build(:appearance, participant: build(:participant, email: "pt2@example.org")),
      ])

      email = JumubaseWeb.Email.registration_success(performance)

      assert email.to == ["pt1@example.org", "pt2@example.org"]
    end
  end
end
