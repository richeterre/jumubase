import Jumubase.Factory
alias Ecto.Changeset
alias Jumubase.Repo
alias Jumubase.JumuParams
alias Jumubase.Accounts.User
alias Jumubase.Foundation.{Category, Host}

Repo.transaction fn ->
  # Clear existing data
  Repo.delete_all(Host)
  Repo.delete_all(User)
  Repo.delete_all(Category)

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

  contest1 = insert(:contest, host: host1)
  contest2 = insert(:contest, host: host2)
  contest3 = insert(:contest,
    start_date: %{day: 1, month: 1, year: year},
    end_date: %{day: 1, month: 1, year: year},
    host: host3
  )
  contest4 = insert(:contest, %{
    host: host1,
    round: 2,
    start_date: %{day: 15, month: 3, year: year},
    end_date: %{day: 17, month: 3, year: year},
    deadline: %{day: 28, month: 2, year: year}
  })

  # Create demo categories

  vocal = insert(:category, name: "Gesang solo", short_name: "Gesang", genre: "classical", type: "solo")
  wind_ens = insert(:category, name: "Bläser-Ensemble", short_name: "BläserEns", genre: "classical", type: "ensemble")
  pop_drums = insert(:category, name: "Drumset (Pop) solo", short_name: "PopDrums", genre: "popular", type: "solo")
  pop_vocal_ens = insert(:category, name: "Vokal-Ensemble (Pop)", short_name: "PopVokalEns", genre: "popular", type: "ensemble")

  # Create demo contest categories

  _lw_vocal = insert(:contest_category, %{
    contest: contest4,
    category: vocal,
    min_age_group: "II",
    max_age_group: "VII",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VII"
  })
  _lw_wind_ens = insert(:contest_category, %{
    contest: contest4,
    category: wind_ens,
    min_age_group: "II",
    max_age_group: "VI",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VI"
  })
  _lw_pop_drums = insert(:contest_category, %{
    contest: contest4,
    category: pop_drums,
    min_age_group: "II",
    max_age_group: "VI",
    min_advancing_age_group: "III",
    max_advancing_age_group: "VI"
  })
  _lw_pop_vocal_ens = insert(:contest_category, %{
    contest: contest4,
    category: pop_vocal_ens,
    min_age_group: "III",
    max_age_group: "VII",
    min_advancing_age_group: nil,
    max_advancing_age_group: nil
  })

  # Add contest categories and demo performances to contests

  for rw_contest <- [contest1, contest2, contest3] do
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

    rw_vocal_perf = insert(:performance, contest_category: rw_vocal, age_group: "III")
    insert(:appearance, performance: rw_vocal_perf, role: "soloist", instrument: "vocals")
    insert(:appearance, performance: rw_vocal_perf, role: "accompanist", instrument: "piano")

    rw_wind_ens_perf = insert(:performance, contest_category: rw_wind_ens, age_group: "III")
    insert(:appearance, performance: rw_wind_ens_perf, role: "ensemblist", instrument: "clarinet")
    insert(:appearance, performance: rw_wind_ens_perf, role: "ensemblist", instrument: "oboe")
    insert(:appearance, performance: rw_wind_ens_perf, role: "ensemblist", instrument: "bassoon")

    rw_pop_drums_perf = insert(:performance, contest_category: rw_pop_drums, age_group: "III")
    insert(:appearance, performance: rw_pop_drums_perf, role: "soloist", instrument: "drumset")
    insert(:appearance, performance: rw_pop_drums_perf, role: "accompanist", instrument: "vocals")
    insert(:appearance, performance: rw_pop_drums_perf, role: "accompanist", instrument: "e-guitar")
    insert(:appearance, performance: rw_pop_drums_perf, role: "accompanist", instrument: "saxophone")

    rw_pop_vocal_ens_perf = insert(:performance, contest_category: rw_pop_vocal_ens, age_group: "III")
    insert_list(2, :appearance, performance: rw_pop_vocal_ens_perf, role: "ensemblist", instrument: "vocals")
    insert(:appearance, performance: rw_pop_vocal_ens_perf, role: "accompanist", instrument: "e-guitar")
    insert(:appearance, performance: rw_pop_vocal_ens_perf, role: "accompanist", instrument: "e-bass")
    insert(:appearance, performance: rw_pop_vocal_ens_perf, role: "accompanist", instrument: "drumset")
  end
end
