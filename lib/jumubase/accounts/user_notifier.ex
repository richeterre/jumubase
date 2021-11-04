defmodule Jumubase.Accounts.UserNotifier do
  import Bamboo.Email
  import Jumubase.Gettext
  alias Jumubase.Mailer

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(
      user.email,
      dgettext("auth", "Reset your password"),
      dgettext(
        "auth",
        "Open this link now to choose a new password:\n\n%{url}\n\nIf you didn’t request this, please ignore this message.",
        url: url
      )
    )
  end

  # Private helpers

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    sender = Application.get_env(:jumubase, JumubaseWeb.Email)[:default_sender]

    email =
      new_email()
      |> to(recipient)
      |> from(sender)
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver_now(email) do
      {:ok, email}
    end
  end
end
