defmodule JumubaseWeb.SessionController do
  use JumubaseWeb, :controller

  import JumubaseWeb.Authorize
  alias Jumubase.Accounts
  alias Phauxth.Confirm.Login

  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => params}) do
    case Login.verify(params, Accounts) do
      {:ok, user} ->
        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))

        Login.add_session(conn, session_id, user.id)
        |> add_remember_me(user.id, params)
        |> login_success(internal_page_path(conn, :home))

      {:error, message} ->
        error(conn, message, session_path(conn, :new))
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    <<session_id::binary-size(17), _::binary>> = get_session(conn, :phauxth_session_id)
    Accounts.delete_session(user, session_id)

    delete_session(conn, :phauxth_session_id)
    |> Phauxth.Remember.delete_rem_cookie()
    |> success(dgettext("auth", "You are now logged out."), page_path(conn, :home))
  end

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Phauxth.Remember.add_rem_cookie(conn, user_id)
  end
  defp add_remember_me(conn, _, _), do: conn
end
