import Jumubase.Factory
alias Jumubase.Repo
alias Jumubase.Accounts.User
alias Jumubase.Foundation.{Category, Host}
alias Jumubase.Showtime.{Participant}

Repo.transaction fn ->
  # Clear existing data
  Repo.delete_all(Host)
  Repo.delete_all(User)
  Repo.delete_all(Category)
  Repo.delete_all(Participant)

  # Create hosts

  insert(:host, name: "DS Bratislava", city: "Bratislava", country_code: "SK", time_zone: "Europe/Bratislava", latitude: 48.1491521, longitude: 17.103554)
  insert(:host, name: "DS Brüssel", city: "Brüssel", country_code: "BE", time_zone: "Europe/Brussels", latitude: 50.8519895, longitude: 4.4926787)
  insert(:host, name: "DS Budapest", city: "Budapest", country_code: "HU", time_zone: "Europe/Budapest", latitude: 47.51, longitude: 18.983813)
  insert(:host, name: "DS Dublin", city: "Dublin", country_code: "IE", time_zone: "Europe/Dublin", latitude: 53.303453, longitude: -6.2293214)
  insert(:host, name: "DS Genf", city: "Genf", country_code: "CH", time_zone: "Europe/Zurich", latitude: 46.2181677, longitude: 6.0874632)
  insert(:host, name: "DS Helsinki", city: "Helsinki", country_code: "FI", time_zone: "Europe/Helsinki", latitude: 60.167165, longitude: 24.93205)
  insert(:host, name: "DS Kopenhagen", city: "Kopenhagen", country_code: "DK", time_zone: "Europe/Copenhagen", latitude: 55.6800835, longitude: 12.5695033)
  insert(:host, name: "DS London", city: "London", country_code: "GB", time_zone: "Europe/London", latitude: 51.4451339, longitude: -0.3050807)
  insert(:host, name: "DS Moskau", city: "Moskau", country_code: "RU", time_zone: "Europe/Moscow", latitude: 55.6643808, longitude: 37.4953562)
  insert(:host, name: "DS Oslo", city: "Oslo", country_code: "NO", time_zone: "Europe/Oslo", latitude: 59.9249933, longitude: 10.7251024)
  insert(:host, name: "DS Paris", city: "Paris", country_code: "FR", time_zone: "Europe/Paris", latitude: 48.8423042, longitude: 2.2035179)
  insert(:host, name: "DS Prag", city: "Prag", country_code: "CZ", time_zone: "Europe/Prague", latitude: 50.0556074, longitude: 14.3541417)
  insert(:host, name: "DS Sofia", city: "Sofia", country_code: "BG", time_zone: "Europe/Sofia", latitude: 42.6691648, longitude: 23.3492821)
  insert(:host, name: "DS Stockholm", city: "Stockholm", country_code: "SE", time_zone: "Europe/Stockholm", latitude: 59.3422421, longitude: 18.0699085)
  insert(:host, name: "DS Warschau", city: "Warschau", country_code: "PL", time_zone: "Europe/Warsaw", latitude: 52.1577924, longitude: 21.0691116)
  insert(:host, name: "DS Doha", city: "Doha", country_code: "QA", time_zone: "Asia/Qatar", latitude: 25.2559086, longitude: 51.501849)

  # Create categories

  insert(:category, name: "\"Kinder musizieren\"", short_name: "Kimu", genre: "kimu", type: "solo_or_ensemble")

  insert(:category, name: "Akkordeon solo", short_name: "Akkordeon", genre: "classical", type: "solo")
  insert(:category, name: "Blockflöte solo", short_name: "Blockflöte", genre: "classical", type: "solo")
  insert(:category, name: "Fagott solo", short_name: "Fagott", genre: "classical", type: "solo")
  insert(:category, name: "Gesang solo", short_name: "Gesang", genre: "classical", type: "solo")
  insert(:category, name: "Gitarre solo", short_name: "Gitarre", genre: "classical", type: "solo")
  insert(:category, name: "Harfe solo", short_name: "Harfe", genre: "classical", type: "solo")
  insert(:category, name: "Horn solo", short_name: "Horn", genre: "classical", type: "solo")
  insert(:category, name: "Kantele solo", short_name: "Kantele", genre: "classical", type: "solo")
  insert(:category, name: "Klarinette solo", short_name: "Klarinette", genre: "classical", type: "solo")
  insert(:category, name: "Klavier solo", short_name: "Klavier", genre: "classical", type: "solo")
  insert(:category, name: "Kontrabass solo", short_name: "Kontrabass", genre: "classical", type: "solo")
  insert(:category, name: "Mallets solo", short_name: "Mallets", genre: "classical", type: "solo")
  insert(:category, name: "Mandoline solo", short_name: "Mandoline", genre: "classical", type: "solo")
  insert(:category, name: "Oboe solo", short_name: "Oboe", genre: "classical", type: "solo")
  insert(:category, name: "Orgel solo", short_name: "Orgel", genre: "classical", type: "solo")
  insert(:category, name: "Percussion solo", short_name: "Percussion", genre: "classical", type: "solo")
  insert(:category, name: "Posaune solo", short_name: "Posaune", genre: "classical", type: "solo")
  insert(:category, name: "Querflöte solo", short_name: "Querflöte", genre: "classical", type: "solo")
  insert(:category, name: "Saxophon solo", short_name: "Saxophon", genre: "classical", type: "solo")
  insert(:category, name: "Tenorhorn/Bariton/Euphonium solo", short_name: "ThBarEuph", genre: "classical", type: "solo")
  insert(:category, name: "Trompete/Flügelhorn solo", short_name: "Trompete", genre: "classical", type: "solo")
  insert(:category, name: "Tuba solo", short_name: "Tuba", genre: "classical", type: "solo")
  insert(:category, name: "Viola solo", short_name: "Viola", genre: "classical", type: "solo")
  insert(:category, name: "Violine solo", short_name: "Violine", genre: "classical", type: "solo")
  insert(:category, name: "Violoncello solo", short_name: "Cello", genre: "classical", type: "solo")
  insert(:category, name: "Zither solo", short_name: "Zither", genre: "classical", type: "solo")

  insert(:category, name: "Akkordeon-Kammermusik", short_name: "AkkKammer", genre: "classical", type: "ensemble")
  insert(:category, name: "Besondere Ensembles: Alte Musik", short_name: "BesEnsAlteMusik", genre: "classical", type: "ensemble")
  insert(:category, name: "Besondere Ensembles: Klassik, Romantik, Spätromantik & Klassische Moderne", short_name: "BesEnsKlassik", genre: "classical", type: "ensemble")
  insert(:category, name: "Bläser-Ensemble", short_name: "BläserEns", genre: "classical", type: "ensemble")
  insert(:category, name: "Duo: Klavier & Blasinstrument", short_name: "Klavier+Bläser", genre: "classical", type: "ensemble")
  insert(:category, name: "Duo: Klavier & Streichinstrument", short_name: "Klavier+Streicher", genre: "classical", type: "ensemble")
  insert(:category, name: "Duo Kunstlied", short_name: "Kunstlied", genre: "classical", type: "ensemble")
  insert(:category, name: "Harfen-Ensemble", short_name: "HarfenEns", genre: "classical", type: "ensemble")
  insert(:category, name: "Klavier-Kammermusik", short_name: "KlavierKammer", genre: "classical", type: "ensemble")
  insert(:category, name: "Klavier vierhändig", short_name: "Klavier4H", genre: "classical", type: "ensemble")
  insert(:category, name: "Neue Musik", short_name: "NeueMusik", genre: "classical", type: "ensemble")
  insert(:category, name: "Schlagzeug-Ensemble", short_name: "SchlagzEns", genre: "classical", type: "ensemble")
  insert(:category, name: "Streicher-Ensemble", short_name: "StreicherEns", genre: "classical", type: "ensemble")
  insert(:category, name: "Vokal-Ensemble", short_name: "VokalEns", genre: "classical", type: "ensemble")
  insert(:category, name: "Zupf-Ensemble", short_name: "ZupfEns", genre: "classical", type: "ensemble")

  insert(:category, name: "Drumset (Pop) solo", short_name: "PopDrums", genre: "popular", type: "solo")
  insert(:category, name: "E-Bass (Pop) solo", short_name: "PopBass", genre: "popular", type: "solo")
  insert(:category, name: "Gesang (Pop) solo", short_name: "PopGesang", genre: "popular", type: "solo")
  insert(:category, name: "Gitarre (Pop) solo", short_name: "PopGitarre", genre: "popular", type: "solo")
  insert(:category, name: "Instrumental-Solo (Pop)", short_name: "PopInstr", genre: "popular", type: "solo")
  insert(:category, name: "Musical", short_name: "Musical", genre: "popular", type: "solo")

  insert(:category, name: "Vokal-Ensemble (Pop)", short_name: "PopVokalEns", genre: "popular", type: "ensemble")
end