defmodule JumubaseWeb.EmailTest do
  use JumubaseWeb.ConnCase

  describe "registration_success/1" do
    setup do
      [contest: insert(:contest)]
    end

    test "composes an email to confirm a Jumu registration", %{contest: c} do
      cc = insert_contest_category(c, "classical")
      performance = insert_performance(cc,
        appearances: build_appearances(["pt@example.org"])
      )
      cat_name = cc.category.name

      email = JumubaseWeb.Email.registration_success(performance)

      assert email.to == "pt@example.org"
      assert email.subject == "Your Jumu registration for category \"#{cat_name}\""
      assert email.html_body =~ cat_name
      assert email.html_body =~ performance.edit_code
      assert email.html_body =~ page_url(JumubaseWeb.Endpoint, :edit_registration)
    end

    test "addresses the email to all participants in a Jumu registration", %{contest: c} do
      cc = insert_contest_category(c, "popular")
      performance = insert_performance(cc,
        appearances: build_appearances(["pt1@example.org", "pt2@example.org"])
      )
      cat_name = cc.category.name

      email = JumubaseWeb.Email.registration_success(performance)

      assert email.to == ["pt1@example.org", "pt2@example.org"]
      assert email.subject == "Your Jumu registration for category \"#{cat_name}\""
    end

    test "adjusts the subject when confirming a Kimu registration", %{contest: c} do
      cc = insert_contest_category(c, "kimu")
      performance = insert_performance(cc,
        appearances: build_appearances(["pt@example.org"])
      )

      email = JumubaseWeb.Email.registration_success(performance)

      assert email.to == "pt@example.org"
      assert email.subject == "Your Kimu registration"
      assert email.html_body =~ performance.edit_code
      assert email.html_body =~ page_url(JumubaseWeb.Endpoint, :edit_registration)
    end
  end

  # Private helpers

  defp build_appearances(participant_emails) do
    Enum.map(participant_emails, fn email ->
      build(:appearance, participant: build(:participant, email: email))
    end)
  end
end
