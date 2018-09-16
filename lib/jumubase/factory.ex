defmodule Jumubase.Factory do
  use ExMachina.Ecto, repo: Jumubase.Repo
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Contest, Host}

  @season 56

  def contest_factory do
    year = JumuParams.year(@season)
    %Contest{
      season: @season,
      round: 1,
      host: build(:host),
      start_date: %{day: 1, month: 1, year: year},
      end_date: %{day: 2, month: 1, year: year},
      signup_deadline: %{day: 15, month: 12, year: year - 1}
    }
  end

  def host_factory do
    %Host{
      name: sequence(:name, &"Host #{&1}"),
      city: "Jumutown",
      country_code: "DE",
      time_zone: "Europe/Berlin"
    }
  end

  def user_factory do
    %User{
      first_name: "Aaron",
      last_name: "Beerenson",
      email: sequence(:email, &"user-#{&1}@example.org"),
      role: "local-organizer"
    }
  end
end
