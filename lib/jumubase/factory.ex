defmodule Jumubase.Factory do
  use ExMachina.Ecto, repo: Jumubase.Repo
  alias Jumubase.Accounts.User

  def user_factory do
    %User{
      first_name: "Aaron",
      last_name: "Beerenson",
      email: sequence(:email, &"user-#{&1}@example.org"),
      role: "rw-organizer"
    }
  end
end
