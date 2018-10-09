defmodule Jumubase.Factory do
  use ExMachina.Ecto, repo: Jumubase.Repo
  import Jumubase.Showtime.Performance, only: [to_edit_code: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host}
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

  @season 56

  def appearance_factory do
    %Appearance{
      performance: build(:performance),
      participant: build(:participant),
      role: "soloist",
      instrument: "piano",
      age_group: "III",
      points: nil
    }
  end

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
      deadline: %{day: 15, month: 12, year: year - 1}
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

  def participant_factory do
    %Participant{
      given_name: "Parti",
      family_name: sequence(:given_name, &"Cipant #{&1}"),
      birthdate: %{day: 1, month: 1, year: JumuParams.year(@season) - 14},
      phone: "123456789",
      email: sequence(:email, &"participant.#{&1}@example.org")
    }
  end

  def performance_factory do
    %Performance{
      contest_category: build(:contest_category),
      edit_code: sequence(:edit_code, &to_edit_code/1),
      age_group: nil,
    }
  end

  def piece_factory do
    %Piece{
      title: sequence(:piece, &"Piece #{&1}"),
      composer_name: "John Cage",
      composer_born: "1912",
      composer_died: "1992",
      epoch: "f",
      minutes: 4,
      seconds: 33
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
