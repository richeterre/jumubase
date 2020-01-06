import Jumubase.Factory
alias Ecto.Changeset
alias Jumubase.Repo
alias Jumubase.JumuParams
alias Jumubase.Accounts.User
alias Jumubase.Foundation.{Category, Host}
alias Jumubase.Showtime.{Participant}

Repo.transaction(fn ->
  # Clear existing data
  Repo.delete_all(Host)
  Repo.delete_all(User)
  Repo.delete_all(Category)
  Repo.delete_all(Participant)

  # Create demo hosts

  insert(:host,
    name: "DS Barcelona",
    current_grouping: "1",
    city: "Barcelona",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 41.382911,
    longitude: 2.08914
  )

  insert(:host,
    name: "DS Bilbao",
    current_grouping: "1",
    city: "Bilbao",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 43.2597465,
    longitude: -2.9099354
  )

  insert(:host,
    name: "DS Gran Canaria",
    current_grouping: "1",
    city: "Las Palmas de Gran Canaria",
    country_code: "ES",
    time_zone: "Atlantic/Canary",
    latitude: 28.0815451,
    longitude: -15.4718158
  )

  insert(:host,
    name: "DS Lissabon",
    current_grouping: "1",
    city: "Lissabon",
    country_code: "PT",
    time_zone: "Europe/Lisbon",
    latitude: 38.7527909,
    longitude: -9.1857376
  )

  insert(:host,
    name: "DS Madrid",
    current_grouping: "1",
    city: "Madrid",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 40.5068463,
    longitude: -3.7076739
  )

  insert(:host,
    name: "DS Málaga",
    current_grouping: "1",
    city: "Ojén (Málaga)",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 36.5297043,
    longitude: -4.7567107
  )

  insert(:host,
    name: "DS Porto",
    current_grouping: "1",
    city: "Porto",
    country_code: "PT",
    time_zone: "Europe/Lisbon",
    latitude: 41.1464018,
    longitude: -8.65784
  )

  insert(:host,
    name: "DS San Sebastián",
    current_grouping: "1",
    city: "Donostia-San Sebastián",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 43.2982861,
    longitude: -1.9927501
  )

  insert(:host,
    name: "DS Sevilla",
    current_grouping: "1",
    city: "Sevilla",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 37.3910806,
    longitude: -5.9941453
  )

  insert(:host,
    name: "DS Teneriffa",
    current_grouping: "1",
    city: "Tabaiba",
    country_code: "ES",
    time_zone: "Atlantic/Canary",
    latitude: 28.4915469,
    longitude: -16.2923725
  )

  insert(:host,
    name: "DS Valencia",
    current_grouping: "1",
    city: "Valencia",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 39.4821081,
    longitude: -0.3657337
  )

  insert(:host,
    name: "DS Bratislava",
    current_grouping: "2",
    city: "Bratislava",
    country_code: "SK",
    time_zone: "Europe/Bratislava",
    latitude: 48.1491521,
    longitude: 17.103554
  )

  insert(:host,
    name: "DS Brüssel",
    current_grouping: "2",
    city: "Brüssel",
    country_code: "BE",
    time_zone: "Europe/Brussels",
    latitude: 50.8519895,
    longitude: 4.4926787
  )

  insert(:host,
    name: "DS Budapest",
    current_grouping: "2",
    city: "Budapest",
    country_code: "HU",
    time_zone: "Europe/Budapest",
    latitude: 47.51,
    longitude: 18.983813
  )

  host3 =
    insert(:host,
      name: "DS Dublin",
      current_grouping: "2",
      city: "Dublin",
      country_code: "IE",
      time_zone: "Europe/Dublin",
      latitude: 53.303453,
      longitude: -6.2293214
    )

  insert(:host,
    name: "DS Doha",
    current_grouping: "2",
    city: "Doha",
    country_code: "QA",
    time_zone: "Asia/Qatar",
    latitude: 25.2559086,
    longitude: 51.501849
  )

  insert(:host,
    name: "DS Genf",
    current_grouping: "2",
    city: "Genf",
    country_code: "CH",
    time_zone: "Europe/Zurich",
    latitude: 46.2181677,
    longitude: 6.0874632
  )

  host1 =
    insert(:host,
      name: "DS Helsinki",
      current_grouping: "2",
      city: "Helsinki",
      country_code: "FI",
      time_zone: "Europe/Helsinki",
      latitude: 60.167165,
      longitude: 24.93205
    )

  insert(:host,
    name: "DS Kopenhagen",
    current_grouping: "2",
    city: "Kopenhagen",
    country_code: "DK",
    time_zone: "Europe/Copenhagen",
    latitude: 55.6800835,
    longitude: 12.5695033
  )

  insert(:host,
    name: "DS London",
    current_grouping: "2",
    city: "London",
    country_code: "GB",
    time_zone: "Europe/London",
    latitude: 51.4451339,
    longitude: -0.3050807
  )

  insert(:host,
    name: "DS Moskau",
    current_grouping: "2",
    city: "Moskau",
    country_code: "RU",
    time_zone: "Europe/Moscow",
    latitude: 55.6643808,
    longitude: 37.4953562
  )

  insert(:host,
    name: "DS Oslo",
    current_grouping: "2",
    city: "Oslo",
    country_code: "NO",
    time_zone: "Europe/Oslo",
    latitude: 59.9249933,
    longitude: 10.7251024
  )

  insert(:host,
    name: "DS Paris",
    current_grouping: "2",
    city: "Paris",
    country_code: "FR",
    time_zone: "Europe/Paris",
    latitude: 48.8423042,
    longitude: 2.2035179
  )

  insert(:host,
    name: "DS Prag",
    current_grouping: "2",
    city: "Prag",
    country_code: "CZ",
    time_zone: "Europe/Prague",
    latitude: 50.0556074,
    longitude: 14.3541417
  )

  insert(:host,
    name: "DS Sofia",
    current_grouping: "2",
    city: "Sofia",
    country_code: "BG",
    time_zone: "Europe/Sofia",
    latitude: 42.6691648,
    longitude: 23.3492821
  )

  host2 =
    insert(:host,
      name: "DS Stockholm",
      current_grouping: "2",
      city: "Stockholm",
      country_code: "SE",
      time_zone: "Europe/Stockholm",
      latitude: 59.3422421,
      longitude: 18.0699085
    )

  insert(:host,
    name: "DS Warschau",
    current_grouping: "2",
    city: "Warschau",
    country_code: "PL",
    time_zone: "Europe/Warsaw",
    latitude: 52.1577924,
    longitude: 21.0691116
  )

  insert(:host,
    name: "DS Alexandria",
    current_grouping: "3",
    city: "Alexandria",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 31.1675474,
    longitude: 29.8508133
  )

  insert(:host,
    name: "DS Athen",
    current_grouping: "3",
    city: "Athen",
    country_code: "GR",
    time_zone: "Europe/Athens",
    latitude: 38.0363279,
    longitude: 23.7853563
  )

  insert(:host,
    name: "DS Istanbul",
    current_grouping: "3",
    city: "Istanbul",
    country_code: "TR",
    time_zone: "Europe/Istanbul",
    latitude: 41.0279952,
    longitude: 28.9735805
  )

  insert(:host,
    name: "DS Kairo-Ost",
    current_grouping: "3",
    city: "Kairo",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 30.0264896,
    longitude: 31.4210053
  )

  insert(:host,
    name: "DS Mailand",
    current_grouping: "3",
    city: "Mailand",
    country_code: "IT",
    time_zone: "Europe/Rome",
    latitude: 45.4788856,
    longitude: 9.1558576
  )

  insert(:host,
    name: "DS Rom",
    current_grouping: "3",
    city: "Rom",
    country_code: "IT",
    time_zone: "Europe/Rome",
    latitude: 41.890165,
    longitude: 12.4248243
  )

  insert(:host,
    name: "DS Thessaloniki",
    current_grouping: "3",
    city: "Thessaloniki",
    country_code: "GR",
    time_zone: "Europe/Athens",
    latitude: 40.5758298,
    longitude: 22.9855775
  )

  insert(:host,
    name: "DS Kairo-West",
    current_grouping: "3",
    city: "Kairo",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 30.0273617,
    longitude: 31.2520294
  )

  insert(:host,
    name: "DS Jerusalem",
    current_grouping: "3",
    city: "Jerusalem",
    country_code: "PS",
    time_zone: "Asia/Jerusalem",
    latitude: 31.7821572,
    longitude: 35.2234264
  )

  # Create demo stages
  insert(:stage, host: host1, name: "Aula")
  insert(:stage, host: host1, name: "Musikraum")
  insert(:stage, host: host2, name: "Aula")
  insert(:stage, host: host3, name: "Lynn Hall")

  # Create demo users

  User.create_changeset(%User{}, %{
    given_name: "Anna",
    family_name: "Admin",
    email: "admin@example.org",
    password: "password",
    role: "admin"
  })
  |> Repo.insert!()

  User.create_changeset(%User{}, %{
    given_name: "Gustav",
    family_name: "Globalheimer",
    email: "global-org@example.org",
    password: "password",
    role: "global-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host2])
  |> Repo.insert!()

  User.create_changeset(%User{}, %{
    given_name: "Lucie",
    family_name: "Lokalheldin",
    email: "local-org@example.org",
    password: "password",
    role: "local-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host3])
  |> Repo.insert!()

  User.create_changeset(%User{}, %{
    given_name: "Bernd",
    family_name: "Beobachter",
    email: "observer@example.org",
    password: "password",
    role: "observer"
  })
  |> Repo.insert!()

  Repo.update_all(User, set: [confirmed_at: DateTime.utc_now()])

  # Create demo contests

  season = 56
  year = JumuParams.year(season)

  kimu1 = insert(:contest, round: 0, host: host1)
  kimu2 = insert(:contest, round: 0, host: host2)
  rw1 = insert(:contest, round: 1, host: host1)
  rw2 = insert(:contest, round: 1, host: host2)

  rw3 =
    insert(:contest,
      round: 1,
      start_date: %{day: 1, month: 1, year: year},
      end_date: %{day: 1, month: 1, year: year},
      host: host3
    )

  lw =
    insert(:contest, %{
      host: host1,
      round: 2,
      start_date: %{day: 15, month: 3, year: year},
      end_date: %{day: 17, month: 3, year: year},
      deadline: %{day: 28, month: 2, year: year}
    })

  # Create demo categories

  kimu =
    insert(:category,
      name: "\"Kinder musizieren\"",
      short_name: "Kimu",
      genre: "kimu",
      type: "solo_or_ensemble",
      group: "kimu"
    )

  vocal =
    insert(:category,
      name: "Gesang solo",
      short_name: "Gesang",
      genre: "classical",
      type: "solo",
      group: "classical_vocals"
    )

  wind_ens =
    insert(:category,
      name: "Bläser-Ensemble",
      short_name: "BläserEns",
      genre: "classical",
      type: "ensemble",
      group: "wind"
    )

  pop_drums =
    insert(:category,
      name: "Drumset (Pop) solo",
      short_name: "PopDrums",
      genre: "popular",
      type: "solo",
      group: "pop_instrumental"
    )

  pop_vocal_ens =
    insert(:category,
      name: "Vokal-Ensemble (Pop)",
      short_name: "PopVokalEns",
      genre: "popular",
      type: "ensemble",
      group: "pop_vocals"
    )

  # Add contest categories and demo performances to contests

  for kimu_contest <- [kimu1, kimu2] do
    cc = insert(:contest_category, contest: kimu_contest, category: kimu)

    insert_performance(cc,
      appearances: [
        build(:appearance, role: "soloist", instrument: "trumpet"),
        build(:appearance, role: "accompanist", instrument: "piano")
      ]
    )

    insert_performance(cc,
      appearances: [
        build(:appearance, role: "ensemblist", instrument: "guitar"),
        build(:appearance, role: "ensemblist", instrument: "guitar")
      ]
    )
  end

  for rw_contest <- [rw1, rw2, rw3] do
    rw_vocal =
      insert(:contest_category, %{
        contest: rw_contest,
        category: vocal,
        min_age_group: "Ia",
        max_age_group: "VII",
        min_advancing_age_group: "II",
        max_advancing_age_group: "VII"
      })

    rw_wind_ens =
      insert(:contest_category, %{
        contest: rw_contest,
        category: wind_ens,
        min_age_group: "Ia",
        max_age_group: "VI",
        min_advancing_age_group: "II",
        max_advancing_age_group: "VI"
      })

    rw_pop_drums =
      insert(:contest_category, %{
        contest: rw_contest,
        category: pop_drums,
        min_age_group: "Ia",
        max_age_group: "VI",
        min_advancing_age_group: "II",
        max_advancing_age_group: "VI"
      })

    rw_pop_vocal_ens =
      insert(:contest_category, %{
        contest: rw_contest,
        category: pop_vocal_ens,
        min_age_group: "Ia",
        max_age_group: "VII",
        min_advancing_age_group: "III",
        max_advancing_age_group: "VII"
      })

    insert_performance(rw_vocal,
      appearances: [
        build(:appearance, role: "soloist", instrument: "vocals"),
        build(:appearance, role: "accompanist", instrument: "piano")
      ]
    )

    insert_performance(rw_wind_ens,
      appearances: [
        build(:appearance, role: "ensemblist", instrument: "clarinet"),
        build(:appearance, role: "ensemblist", instrument: "oboe"),
        build(:appearance, role: "ensemblist", instrument: "bassoon")
      ]
    )

    insert_performance(rw_pop_drums,
      appearances: [
        build(:appearance, role: "soloist", instrument: "drumset"),
        build(:appearance, role: "accompanist", instrument: "vocals"),
        build(:appearance, role: "accompanist", instrument: "e-guitar"),
        build(:appearance, role: "accompanist", instrument: "saxophone")
      ],
      pieces: build_list(1, :popular_piece)
    )

    insert_performance(rw_pop_vocal_ens,
      appearances: [
        build(:appearance, role: "ensemblist", instrument: "vocals"),
        build(:appearance, role: "ensemblist", instrument: "vocals"),
        build(:appearance, role: "accompanist", instrument: "e-guitar"),
        build(:appearance, role: "accompanist", instrument: "e-bass"),
        build(:appearance, role: "accompanist", instrument: "drumset")
      ],
      pieces: build_list(1, :popular_piece)
    )
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
end)
