defmodule JumubaseWeb.AuthTestHelpers do
  use Phoenix.ConnTest
  import Ecto.Changeset
  import Jumubase.Factory
  alias Jumubase.Repo
  alias Jumubase.JumuParams
  alias Jumubase.Accounts

  def add_user(attrs \\ []) do
    # Add password since Factory doesn't set one
    attrs = attrs |> Keyword.put_new(:password, "reallyHard2gue$$")

    user = params_for(:user, attrs)
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_reset_user(email) do
    add_user(email: email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def gen_key(email) do
    Phauxth.Token.sign(JumubaseWeb.Endpoint, %{"email" => email})
  end

  def all_roles, do: JumuParams.user_roles()

  def non_admin_roles, do: List.delete(JumuParams.user_roles(), "admin")
end
