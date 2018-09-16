defmodule Jumubase.Factory do
  use ExMachina.Ecto, repo: Jumubase.Repo
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host}

  @season 56

  def category_factory do
    %Category{
      name: sequence(:name, &"Category #{&1}"),
      short_name: sequence(:short_name, &"Cat #{&1}"),
      genre: "classical",
      type: "solo"
    }
  end

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

  def contest_category_factory do
    %ContestCategory{
      contest: build(:contest),
      category: build(:category),
      min_age_group: "Ia",
      max_age_group: "VI",
      min_advancing_age_group: "II",
      max_advancing_age_group: "VI"
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
