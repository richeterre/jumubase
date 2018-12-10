defmodule JumubaseWeb.PasswordResetController do
  use JumubaseWeb, :controller

  import JumubaseWeb.Authorize
  alias Jumubase.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    cond do
      String.match?(email, ~r/@/) ->
        key = Accounts.create_password_reset(JumubaseWeb.Endpoint, %{"email" => email})
        Accounts.Message.reset_request(email, key)
        message = dgettext("auth", "Check your inbox for instructions on how to reset your password")
        success(conn, message, Routes.session_path(conn, :new))
      true ->
        error(conn, dgettext("auth", "Please enter an email address"), Routes.password_reset_path(conn, :new))
    end
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end
  def edit(conn, _params) do
    render(conn, JumubaseWeb.ErrorView, "404.html")
  end

  def update(conn, %{"password_reset" => params}) do
    case Phauxth.Confirm.verify(params, Accounts, mode: :pass_reset) do
      {:ok, user} ->
        Accounts.update_password(user, params) |> update_password(conn, params)

      {:error, message} ->
        put_flash(conn, :error, message)
        |> render("edit.html", key: params["key"])
    end
  end

  defp update_password({:ok, _user}, conn, _params) do
    message = dgettext("auth", "Your password has been reset.")

    delete_session(conn, :phauxth_session_id)
    |> success(message, Routes.session_path(conn, :new))
  end
  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    conn
    |> put_flash(:error, message)
    |> render("edit.html", key: params["key"])
  end
end
