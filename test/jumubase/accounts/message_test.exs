defmodule Jumubase.Accounts.MessageTest do
  use ExUnit.Case
  use Bamboo.Test
  import JumubaseWeb.AuthTestHelpers
  import JumubaseWeb.Router.Helpers, only: [password_reset_url: 3]
  alias Jumubase.Accounts.Message

  setup do
    email = "deirdre@example.com"
    {:ok, %{email: email, key: gen_key(email)}}
  end

  test "sends no user found message for password reset attempt" do
    sent_email = Message.reset_request("gladys@example.com", nil)
    assert sent_email.text_body =~ "but no user was found for the email you provided"
  end

  test "sends reset password request email", %{email: email, key: key} do
    sent_email = Message.reset_request(email, key)
    expected_url = password_reset_url(JumubaseWeb.Endpoint, :edit, key: key)
    assert sent_email.subject =~ "Reset your password"
    assert sent_email.text_body =~ "choose a new password: #{expected_url}"
    assert_delivered_email(Message.reset_request(email, key))
  end

  test "sends password reset email", %{email: email} do
    sent_email = Message.reset_success(email)
    assert sent_email.text_body =~ "password has been reset"
    assert_delivered_email(Message.reset_success(email))
  end
end
