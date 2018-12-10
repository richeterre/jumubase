defmodule Jumubase.Accounts.Message do
  @moduledoc """
  A module for sending email messages to the user.
  """

  import Bamboo.Email
  import Jumubase.Gettext
  alias JumubaseWeb.Router.Helpers, as: Routes
  alias Jumubase.Mailer

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    prep_mail(address)
    |> subject(dgettext("auth", "Reset your password"))
    |> text_body(
      dgettext("auth", "You tried to reset your password, but no user was found for the email you provided.")
    )
    |> Mailer.deliver_now()
  end
  def reset_request(address, key) do
    url = Routes.password_reset_url(JumubaseWeb.Endpoint, :edit, key: key)
    prep_mail(address)
    |> subject(dgettext("auth", "Reset your password"))
    |> text_body(dgettext("auth", "Open this link now to choose a new password: %{url}", url: url))
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    sender = Application.get_env(:jumubase, JumubaseWeb.Email)[:default_sender]

    new_email()
    |> to(address)
    |> from(sender)
  end
end
