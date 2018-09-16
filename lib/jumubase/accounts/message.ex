defmodule Jumubase.Accounts.Message do
  @moduledoc """
  A module for sending email messages to the user.
  """

  import Bamboo.Email
  import Jumubase.Gettext
  import JumubaseWeb.Router.Helpers, only: [password_reset_url: 3]
  alias Jumubase.Mailer

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    prep_mail(address)
    |> subject("Reset your password")
    |> text_body(
        gettext("You requested a password reset, but no user is associated with the email you provided.")
      )
    |> Mailer.deliver_now()
  end
  def reset_request(address, key) do
    url = password_reset_url(JumubaseWeb.Endpoint, :edit, key: key)
    prep_mail(address)
    |> subject(gettext("Reset your password"))
    |> text_body(gettext("Reset your password at %{url}", url: url))
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    prep_mail(address)
    |> subject(gettext("Password reset"))
    |> text_body(gettext("Your password has been reset."))
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
  end
end
