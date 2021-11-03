defmodule JumubaseWeb.UserSessionController do
  use JumubaseWeb, :controller
  alias Jumubase.Accounts
  alias JumubaseWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      conn
      |> put_flash(
        :error,
        dgettext("auth", "Unfortunately, the email or password was incorrect.")
      )
      |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, dgettext("auth", "You are now logged out."))
    |> UserAuth.log_out_user()
  end
end
