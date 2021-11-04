defmodule Jumubase.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jumubase.Accounts` context.
  """

  def valid_user_password, do: "hello world!"

  def user_fixture do
    {:ok, user} =
      Jumubase.Factory.params_for(:user, password: valid_user_password())
      |> Jumubase.Accounts.create_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
