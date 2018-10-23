import Jumubase.Factory
alias Ecto.Changeset
alias Jumubase.Repo
alias Jumubase.JumuParams
alias Jumubase.Accounts.User
alias Jumubase.Foundation.{Category, Host}
alias Jumubase.Showtime.{Participant}

Repo.transaction fn ->
  # Clear existing data
  Repo.delete_all(Host)
  Repo.delete_all(User)
  Repo.delete_all(Category)
  Repo.delete_all(Participant)

  # Create demo hosts

  host1 = Repo.insert!(%Host{name: "DS Helsinki", city: "Helsinki", country_code: "FI", time_zone: "Europe/Helsinki"})
  host2 = Repo.insert!(%Host{name: "DS Stockholm", city: "Stockholm", country_code: "SE", time_zone: "Europe/Stockholm"})
  host3 = Repo.insert!(%Host{name: "DS Dublin", city: "Dublin", country_code: "IE", time_zone: "Europe/Dublin"})

  # Create demo users

  User.create_changeset(%User{}, %{
    first_name: "Anna",
    last_name: "Admin",
    email: "admin@example.org",
    password: "password",
    role: "admin"
  })
  |> Repo.insert!

  User.create_changeset(%User{}, %{
    first_name: "Gustav",
    last_name: "Globalheimer",
    email: "global-org@example.org",
    password: "password",
    role: "global-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host2])
  |> Repo.insert!

  User.create_changeset(%User{}, %{
    first_name: "Lucie",
    last_name: "Lokalheldin",
    email: "local-org@example.org",
    password: "password",
    role: "local-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host3])
  |> Repo.insert!

  User.create_changeset(%User{}, %{
    first_name: "Bernd",
    last_name: "Beobachter",
    email: "inspector@example.org",
    password: "password",
    role: "inspector"
  })
  |> Repo.insert!

  Repo.update_all(User, set: [confirmed_at: DateTime.utc_now()])

  # Create demo contests

  season = 56
  year = JumuParams.year(season)

  kimu1 = insert(:contest, round: 0, host: host1)
  kimu2 = insert(:contest, round: 0, host: host2)
  rw1 = insert(:contest, round: 1, host: host1)
  rw2 = insert(:contest, round: 1, host: host2)
  rw3 = insert(:contest,
    round: 1,
    start_date: %{day: 1, month: 1, year: year},
    end_date: %{day: 1, month: 1, year: year},
    host: host3
  )
  lw = insert(:contest, %{
    host: host1,
    round: 2,
    start_date: %{day: 15, month: 3, year: year},
    end_date: %{day: 17, month: 3, year: year},
    deadline: %{day: 28, month: 2, year: year}
  })

  # Create demo categories

  kimu = insert(:category, name: "\"Kinder musizieren\"", short_name: "Kimu", genre: "kimu", type: "solo_or_ensemble")
  vocal = insert(:category, name: "Gesang solo", short_name: "Gesang", genre: "classical", type: "solo")
  wind_ens = insert(:category, name: "Bläser-Ensemble", short_name: "BläserEns", genre: "classical", type: "ensemble")
  pop_drums = insert(:category, name: "Drumset (Pop) solo", short_name: "PopDrums", genre: "popular", type: "solo")
  pop_vocal_ens = insert(:category, name: "Vokal-Ensemble (Pop)", short_name: "PopVokalEns", genre: "popular", type: "ensemble")

  # Add contest categories and demo performances to contests

  for kimu_contest <- [kimu1, kimu2] do
    insert(:contest_category, contest: kimu_contest, category: kimu)
  end

  for rw_contest <- [rw1, rw2, rw3] do
    rw_vocal = insert(:contest_category, %{
      contest: rw_contest,
      category: vocal,
      min_age_group: "Ia",
      max_age_group: "VII",
      min_advancing_age_group: "II",
      max_advancing_age_group: "VII"
    })
    rw_wind_ens = insert(:contest_category, %{
      contest: rw_contest,
      category: wind_ens,
      min_age_group: "Ia",
      max_age_group: "VI",
      min_advancing_age_group: "II",
      max_advancing_age_group: "VI"
    })
    rw_pop_drums = insert(:contest_category, %{
      contest: rw_contest,
      category: pop_drums,
      min_age_group: "Ia",
      max_age_group: "VI",
      min_advancing_age_group: "II",
      max_advancing_age_group: "VI"
    })
    rw_pop_vocal_ens = insert(:contest_category, %{
      contest: rw_contest,
      category: pop_vocal_ens,
      min_age_group: "Ia",
      max_age_group: "VII",
      min_advancing_age_group: "III",
      max_advancing_age_group: "VII"
    })

    insert_performance(rw_vocal, appearances: [
      build(:appearance, role: "soloist", instrument: "vocals"),
      build(:appearance, role: "accompanist", instrument: "piano"),
    ])

    insert_performance(rw_wind_ens, appearances: [
      build(:appearance, role: "ensemblist", instrument: "clarinet"),
      build(:appearance, role: "ensemblist", instrument: "oboe"),
      build(:appearance, role: "ensemblist", instrument: "bassoon"),
    ])

    insert_performance(rw_pop_drums, appearances: [
      build(:appearance, role: "soloist", instrument: "drumset"),
      build(:appearance, role: "accompanist", instrument: "vocals"),
      build(:appearance, role: "accompanist", instrument: "e-guitar"),
      build(:appearance, role: "accompanist", instrument: "saxophone"),
    ], pieces: build_list(1, :popular_piece))

    insert_performance(rw_pop_vocal_ens, appearances: [
      build(:appearance, role: "ensemblist", instrument: "vocals"),
      build(:appearance, role: "ensemblist", instrument: "vocals"),
      build(:appearance, role: "accompanist", instrument: "e-guitar"),
      build(:appearance, role: "accompanist", instrument: "e-bass"),
      build(:appearance, role: "accompanist", instrument: "drumset"),
    ], pieces: build_list(1, :popular_piece))
  end

  insert(:contest_category, %{
    contest: lw,
    category: vocal,
    min_age_group: "II",
    max_age_group: "VII",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VII"
  })
  insert(:contest_category, %{
    contest: lw,
    category: wind_ens,
    min_age_group: "II",
    max_age_group: "VI",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VI"
  })
  insert(:contest_category, %{
    contest: lw,
    category: pop_drums,
    min_age_group: "II",
    max_age_group: "VI",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VI"
  })
  insert(:contest_category, %{
    contest: lw,
    category: pop_vocal_ens,
    min_age_group: "III",
    max_age_group: "VII",
    min_advancing_age_group: nil,
    max_advancing_age_group: nil
  })
end
