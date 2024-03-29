defmodule JumubaseWeb.ContactController do
  use JumubaseWeb, :controller
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Jumubase.Mailer
  alias Jumubase.Utils
  alias JumubaseWeb.Email

  def send_message(conn, %{"contact" => params}) do
    changeset = contact_message_changeset(params)

    cond do
      not changeset.valid? ->
        conn
        |> put_flash(:error, gettext("Please fill in all fields and try again!"))
        |> redirect(to: Routes.page_path(conn, :contact))

      # Detect spambots via "trap" field invisible to humans
      params["email_repeat"] != "" ->
        conn
        |> put_flash(:error, gettext("Please fill in only fields that are visible in the form."))
        |> redirect(to: Routes.page_path(conn, :contact))

      true ->
        changeset.changes
        |> Email.contact_message()
        |> Mailer.deliver()

        conn
        |> put_flash(:success, gettext("Your message has been sent!"))
        |> redirect(to: Routes.page_path(conn, :contact))
    end
  end

  # Private helpers

  # Casts and validates a contact message from the given params.
  defp contact_message_changeset(params) do
    data = %{}
    types = %{name: :string, email: :string, message: :string}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> validate_required([:name, :email, :message])
    |> validate_format(:email, Utils.email_format())
    |> update_change(:name, &String.trim/1)
    |> update_change(:email, &String.trim/1)
    |> update_change(:message, &String.trim/1)
  end
end
