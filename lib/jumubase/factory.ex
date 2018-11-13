defmodule Jumubase.Factory do
  use ExMachina.Ecto, repo: Jumubase.Repo
  import Jumubase.Showtime.Performance, only: [to_edit_code: 2]
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host}
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

  @season 56

  # Factories

  def appearance_factory do
    %Appearance{
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
      address: "c/o Jane Doe<br>Jumu Lane 1<br>Jumutown",
      city: "Jumutown",
      country_code: "DE",
      time_zone: "Europe/Berlin",
      latitude: 51.163375,
      longitude: 10.447683,
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
      appearances: build_list(1, :appearance),
      pieces: build_list(1, :piece),
      age_group: "III",
    }
  end

  def piece_factory do
    %Piece{
      title: sequence(:piece, &"Piece #{&1}"),
      composer: "John Cage",
      composer_born: "1912",
      composer_died: "1992",
      epoch: "f",
      minutes: 4,
      seconds: 33
    }
  end

  def popular_piece_factory do
    %Piece{
      title: sequence(:piece, &"Song #{&1}"),
      artist: "Johnny Cash",
      epoch: "e",
      minutes: 3,
      seconds: 44
    }
  end

  def user_factory do
    %User{
      given_name: "Aaron",
      family_name: "Beerenson",
      email: sequence(:email, &"user-#{&1}@example.org"),
      role: "local-organizer"
    }
  end

  # Pipeable functions

  def with_contest_categories(%Contest{} = contest) do
    ccs = insert_pair(:contest_category, contest: contest)
    %{contest | contest_categories: ccs}
  end

  # Insertion helpers

  def insert_contest_category(%Contest{} = contest) do
    insert(:contest_category, contest: contest)
  end
  def insert_contest_category(%Contest{} = contest, genre) do
    insert(:contest_category,
      contest: contest,
      category: build(:category, genre: genre)
    )
  end

  @doc """
  Inserts a performance into the given entity.
  """
  def insert_performance(_entity, attrs \\ [])
  def insert_performance(%Contest{} = contest, attrs) do
    attrs =
      attrs
      |> Keyword.put_new(:contest_category, build(:contest_category, contest: contest))
      |> Keyword.put_new(:edit_code, generate_edit_code(contest.round))

    insert(:performance, attrs)
  end
  def insert_performance(%ContestCategory{contest: c} = cc, attrs) do
    attrs =
      attrs
      |> Keyword.put(:contest_category, cc)
      |> Keyword.put_new(:edit_code, generate_edit_code(c.round))

    insert(:performance, attrs)
  end

  @doc """
  Inserts a participant into the given contest.
  """
  def insert_participant(%Contest{} = c, attrs \\ []) do
    %{appearances: [a]} = insert_performance(c, appearances: [
      build(:appearance, participant: build(:participant, attrs))
    ])
    a.participant
  end

  # Private helpers

  # Generates a unique edit code with the given round.
  defp generate_edit_code(round) do
    sequence(:edit_code, &to_edit_code(&1, round))
  end
end
