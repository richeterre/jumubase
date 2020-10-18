import Jumubase.Factory
alias Jumubase.Repo

Repo.transaction(fn ->
  # Create hosts

  insert(:host,
    name: "Barcelona",
    current_grouping: "1",
    city: "Barcelona",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 41.382911,
    longitude: 2.08914
  )

  insert(:host,
    name: "Bilbao",
    current_grouping: "1",
    city: "Bilbao",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 43.2597465,
    longitude: -2.9099354
  )

  insert(:host,
    name: "Gran Canaria",
    current_grouping: "1",
    city: "Las Palmas de Gran Canaria",
    country_code: "ES",
    time_zone: "Atlantic/Canary",
    latitude: 28.0815451,
    longitude: -15.4718158
  )

  insert(:host,
    name: "Lissabon",
    current_grouping: "1",
    city: "Lissabon",
    country_code: "PT",
    time_zone: "Europe/Lisbon",
    latitude: 38.7527909,
    longitude: -9.1857376
  )

  insert(:host,
    name: "Madrid",
    current_grouping: "1",
    city: "Madrid",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 40.5068463,
    longitude: -3.7076739
  )

  insert(:host,
    name: "Málaga",
    current_grouping: "1",
    city: "Ojén (Málaga)",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 36.5297043,
    longitude: -4.7567107
  )

  insert(:host,
    name: "Porto",
    current_grouping: "1",
    city: "Porto",
    country_code: "PT",
    time_zone: "Europe/Lisbon",
    latitude: 41.1464018,
    longitude: -8.65784
  )

  insert(:host,
    name: "San Sebastián",
    current_grouping: "1",
    city: "Donostia-San Sebastián",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 43.2982861,
    longitude: -1.9927501
  )

  insert(:host,
    name: "Sevilla",
    current_grouping: "1",
    city: "Sevilla",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 37.3910806,
    longitude: -5.9941453
  )

  insert(:host,
    name: "Teneriffa",
    current_grouping: "1",
    city: "Tabaiba",
    country_code: "ES",
    time_zone: "Atlantic/Canary",
    latitude: 28.4915469,
    longitude: -16.2923725
  )

  insert(:host,
    name: "Valencia",
    current_grouping: "1",
    city: "Valencia",
    country_code: "ES",
    time_zone: "Europe/Madrid",
    latitude: 39.4821081,
    longitude: -0.3657337
  )

  insert(:host,
    name: "Bratislava",
    current_grouping: "2",
    address:
      "c/o [Marianna Gazdíková & Astrid Rajter](mailto:jumu@deutscheschule.sk)<br>Palisády 51<br>811 06 Bratislava<br>Slowakei",
    city: "Bratislava",
    country_code: "SK",
    time_zone: "Europe/Bratislava",
    latitude: 48.1491521,
    longitude: 17.103554
  )

  insert(:host,
    name: "Brüssel",
    current_grouping: "2",
    address: "c/o Konstanze Rommel<br>Lange Eikstraat 71<br>1970 Wezembeek-Oppem<br>Belgien",
    city: "Brüssel",
    country_code: "BE",
    time_zone: "Europe/Brussels",
    latitude: 50.8519895,
    longitude: 4.4926787
  )

  insert(:host,
    name: "Budapest",
    current_grouping: "2",
    address:
      "c/o [Peter Bachmaier](mailto:pbachmaier@deutscheschule.hu)<br>Cinege ut 8/c<br>1121 Budapest<br>Ungarn",
    city: "Budapest",
    country_code: "HU",
    time_zone: "Europe/Budapest",
    latitude: 47.51,
    longitude: 18.983813
  )

  insert(:host,
    name: "Dublin",
    current_grouping: "2",
    address:
      "c/o [Noelle Brennan](mailto:noelle.brennan@kilians.com)<br>Roebuck Road<br>Clonskeagh, Dublin 14<br>Irland",
    city: "Dublin",
    country_code: "IE",
    time_zone: "Europe/Dublin",
    latitude: 53.303453,
    longitude: -6.2293214
  )

  insert(:host,
    name: "Genf",
    current_grouping: "2",
    address: "c/o Elinor Ziellenbach<br>6, Chemin de Champ-Claude<br>1214 Vernier<br>Schweiz",
    city: "Genf",
    country_code: "CH",
    time_zone: "Europe/Zurich",
    latitude: 46.2181677,
    longitude: 6.0874632
  )

  insert(:host,
    name: "Helsinki",
    current_grouping: "2",
    address:
      "c/o [Robert Bär](mailto:robert.bar@dsh.fi)<br>Malminkatu 14<br>00100 Helsinki<br>Finnland",
    city: "Helsinki",
    country_code: "FI",
    time_zone: "Europe/Helsinki",
    latitude: 60.167165,
    longitude: 24.93205
  )

  insert(:host,
    name: "Kopenhagen",
    current_grouping: "2",
    address:
      "c/o [Angelika Bowes](mailto:ak@adm.sanktpetriskole.dk)<br>Larslejsstræde 5-7<br>1451 København K<br>Dänemark",
    city: "Kopenhagen",
    country_code: "DK",
    time_zone: "Europe/Copenhagen",
    latitude: 55.6800835,
    longitude: 12.5695033
  )

  insert(:host,
    name: "London",
    current_grouping: "2",
    address:
      "c/o [Evelyn Meyer](mailto:evelyn.meyer@dslondon.org.uk)<br>Douglas House, Petersham Road<br>Richmond/Surrey TW 10 7 AH<br>Vereinigtes Königreich",
    city: "London",
    country_code: "GB",
    time_zone: "Europe/London",
    latitude: 51.4451339,
    longitude: -0.3050807
  )

  insert(:host,
    name: "Moskau",
    current_grouping: "2",
    address:
      "c/o [Christiane Beiküfner](mailto:bei@dsmoskau.ru)<br>Prospekt Wernadskogo 103/5<br>119526 Moskau<br>Russland",
    city: "Moskau",
    country_code: "RU",
    time_zone: "Europe/Moscow",
    latitude: 55.6643808,
    longitude: 37.4953562
  )

  insert(:host,
    name: "Oslo",
    current_grouping: "2",
    address:
      "c/o [Katja Maiwald](mailto:katja.maiwald@deutsche-schule.no)<br>Sporveisgata 20<br>0354 Oslo<br>Norwegen",
    city: "Oslo",
    country_code: "NO",
    time_zone: "Europe/Oslo",
    latitude: 59.9249933,
    longitude: 10.7251024
  )

  insert(:host,
    name: "Paris",
    current_grouping: "2",
    address:
      "c/o [Martina Freund](mailto:martina.freund-krueger@idsp.fr)<br>Rue Pasteur 18<br>92 210 Saint Cloud<br>Frankreich",
    city: "Paris",
    country_code: "FR",
    time_zone: "Europe/Paris",
    latitude: 48.8423042,
    longitude: 2.2035179
  )

  insert(:host,
    name: "Prag",
    current_grouping: "2",
    address: "c/o Aleš Kudela<br>Schwarzenberská 1/700<br>15800 Praha 5<br>Tschechische Republik",
    city: "Prag",
    country_code: "CZ",
    time_zone: "Europe/Prague",
    latitude: 50.0556074,
    longitude: 14.3541417
  )

  insert(:host,
    name: "Sofia",
    current_grouping: "2",
    address: "c/o Tiko Barz<br>ul. Joliot Curie 25<br>1113 Sofia<br>Bulgarien",
    city: "Sofia",
    country_code: "BG",
    time_zone: "Europe/Sofia",
    latitude: 42.6691648,
    longitude: 23.3492821
  )

  insert(:host,
    name: "Stockholm",
    current_grouping: "2",
    address:
      "c/o [Irene Rieck](mailto:irene.rieck@tyskaskolan.se)<br>Karlavägen 25<br>11431 Stockholm<br>Schweden",
    city: "Stockholm",
    country_code: "SE",
    time_zone: "Europe/Stockholm",
    latitude: 59.3422421,
    longitude: 18.0699085
  )

  insert(:host,
    name: "Warschau",
    current_grouping: "2",
    address:
      "c/o [Marcin Lemiszewski](mailto:m.lemiszewski@wbs.pl)<br>ul. Sw. Urszuli Ledóchowskiej 3<br>02-972 Warszawa (Wilanów)<br>Polen",
    city: "Warschau",
    country_code: "PL",
    time_zone: "Europe/Warsaw",
    latitude: 52.1577924,
    longitude: 21.0691116
  )

  insert(:host,
    name: "Alexandria",
    current_grouping: "3",
    city: "Alexandria",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 31.1675474,
    longitude: 29.8508133
  )

  insert(:host,
    name: "Athen",
    current_grouping: "3",
    city: "Athen",
    country_code: "GR",
    time_zone: "Europe/Athens",
    latitude: 38.0363279,
    longitude: 23.7853563
  )

  insert(:host,
    name: "Istanbul",
    current_grouping: "3",
    city: "Istanbul",
    country_code: "TR",
    time_zone: "Europe/Istanbul",
    latitude: 41.0279952,
    longitude: 28.9735805
  )

  insert(:host,
    name: "Kairo-Ost",
    current_grouping: "3",
    city: "Kairo",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 30.0264896,
    longitude: 31.4210053
  )

  insert(:host,
    name: "Mailand",
    current_grouping: "3",
    city: "Mailand",
    country_code: "IT",
    time_zone: "Europe/Rome",
    latitude: 45.4788856,
    longitude: 9.1558576
  )

  insert(:host,
    name: "Rom",
    current_grouping: "3",
    city: "Rom",
    country_code: "IT",
    time_zone: "Europe/Rome",
    latitude: 41.890165,
    longitude: 12.4248243
  )

  insert(:host,
    name: "Thessaloniki",
    current_grouping: "3",
    city: "Thessaloniki",
    country_code: "GR",
    time_zone: "Europe/Athens",
    latitude: 40.5758298,
    longitude: 22.9855775
  )

  insert(:host,
    name: "Kairo-West",
    current_grouping: "3",
    city: "Kairo",
    country_code: "EG",
    time_zone: "Africa/Cairo",
    latitude: 30.0273617,
    longitude: 31.2520294
  )

  insert(:host,
    name: "Jerusalem",
    current_grouping: "3",
    city: "Jerusalem",
    country_code: "PS",
    time_zone: "Asia/Jerusalem",
    latitude: 31.7821572,
    longitude: 35.2234264
  )

  # Create categories

  insert(:category,
    name: "\"Kinder musizieren\"",
    short_name: "Kimu",
    genre: "kimu",
    type: "solo_or_ensemble",
    group: "kimu",
    uses_epochs: false
  )

  insert(:category,
    name: "Akkordeon solo",
    short_name: "Akkordeon",
    genre: "classical",
    type: "solo",
    group: "accordion",
    uses_epochs: true
  )

  insert(:category,
    name: "Blockflöte solo",
    short_name: "Blockflöte",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Fagott solo",
    short_name: "Fagott",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Gesang solo",
    short_name: "Gesang",
    genre: "classical",
    type: "solo",
    group: "classical_vocals",
    uses_epochs: true
  )

  insert(:category,
    name: "Gitarre solo",
    short_name: "Gitarre",
    genre: "classical",
    type: "solo",
    group: "plucked",
    uses_epochs: true
  )

  insert(:category,
    name: "Harfe solo",
    short_name: "Harfe",
    genre: "classical",
    type: "solo",
    group: "harp",
    uses_epochs: true
  )

  insert(:category,
    name: "Horn solo",
    short_name: "Horn",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Kantele solo",
    short_name: "Kantele",
    genre: "classical",
    type: "solo",
    group: "plucked",
    uses_epochs: true
  )

  insert(:category,
    name: "Klarinette solo",
    short_name: "Klarinette",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Klavier solo",
    short_name: "Klavier",
    genre: "classical",
    type: "solo",
    group: "piano",
    uses_epochs: true
  )

  insert(:category,
    name: "Kontrabass solo",
    short_name: "Kontrabass",
    genre: "classical",
    type: "solo",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Mallets solo",
    short_name: "Mallets",
    genre: "classical",
    type: "solo",
    group: "percussion",
    uses_epochs: false
  )

  insert(:category,
    name: "Mandoline solo",
    short_name: "Mandoline",
    genre: "classical",
    type: "solo",
    group: "plucked",
    uses_epochs: true
  )

  insert(:category,
    name: "Oboe solo",
    short_name: "Oboe",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Orgel solo",
    short_name: "Orgel",
    genre: "classical",
    type: "solo",
    group: "organ",
    uses_epochs: true
  )

  insert(:category,
    name: "Percussion solo",
    short_name: "Percussion",
    genre: "classical",
    type: "solo",
    group: "percussion",
    uses_epochs: false
  )

  insert(:category,
    name: "Posaune solo",
    short_name: "Posaune",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Querflöte solo",
    short_name: "Querflöte",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Saxophon solo",
    short_name: "Saxophon",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Tenorhorn/Bariton/Euphonium solo",
    short_name: "ThBarEuph",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Trompete/Flügelhorn solo",
    short_name: "Trompete",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Tuba solo",
    short_name: "Tuba",
    genre: "classical",
    type: "solo",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Viola solo",
    short_name: "Viola",
    genre: "classical",
    type: "solo",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Violine solo",
    short_name: "Violine",
    genre: "classical",
    type: "solo",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Violoncello solo",
    short_name: "Cello",
    genre: "classical",
    type: "solo",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Zither solo",
    short_name: "Zither",
    genre: "classical",
    type: "solo",
    group: "plucked",
    uses_epochs: true
  )

  insert(:category,
    name: "Akkordeon-Kammermusik",
    short_name: "AkkKammer",
    genre: "classical",
    type: "ensemble",
    group: "accordion",
    uses_epochs: true
  )

  insert(:category,
    name: "Besondere Ensembles: Alte Musik",
    short_name: "BesEnsAlteMusik",
    genre: "classical",
    type: "ensemble",
    group: "special_lineups",
    uses_epochs: true
  )

  insert(:category,
    name: "Besondere Ensembles: Klassik, Romantik, Spätromantik & Klassische Moderne",
    short_name: "BesEnsKlassik",
    genre: "classical",
    type: "ensemble",
    group: "special_lineups",
    uses_epochs: true
  )

  insert(:category,
    name: "Bläser-Ensemble",
    short_name: "BläserEns",
    genre: "classical",
    type: "ensemble",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Duo: Klavier & Blasinstrument",
    short_name: "Klavier+Bläser",
    genre: "classical",
    type: "ensemble",
    group: "wind",
    uses_epochs: true
  )

  insert(:category,
    name: "Duo: Klavier & Streichinstrument",
    short_name: "Klavier+Streicher",
    genre: "classical",
    type: "ensemble",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Duo Kunstlied",
    short_name: "Kunstlied",
    genre: "classical",
    type: "ensemble",
    group: "classical_vocals",
    uses_epochs: true
  )

  insert(:category,
    name: "Harfen-Ensemble",
    short_name: "HarfenEns",
    genre: "classical",
    type: "ensemble",
    group: "harp",
    uses_epochs: true
  )

  insert(:category,
    name: "Klavier-Kammermusik",
    short_name: "KlavierKammer",
    genre: "classical",
    type: "ensemble",
    group: "piano",
    uses_epochs: true
  )

  insert(:category,
    name: "Klavier vierhändig",
    short_name: "Klavier4H",
    genre: "classical",
    type: "ensemble",
    group: "piano",
    uses_epochs: true
  )

  insert(:category,
    name: "Neue Musik",
    short_name: "NeueMusik",
    genre: "classical",
    type: "ensemble",
    group: "special_lineups",
    uses_epochs: true
  )

  insert(:category,
    name: "Schlagzeug-Ensemble",
    short_name: "SchlagzEns",
    genre: "classical",
    type: "ensemble",
    group: "percussion",
    uses_epochs: false
  )

  insert(:category,
    name: "Streicher-Ensemble",
    short_name: "StreicherEns",
    genre: "classical",
    type: "ensemble",
    group: "strings",
    uses_epochs: true
  )

  insert(:category,
    name: "Vokal-Ensemble",
    short_name: "VokalEns",
    genre: "classical",
    type: "ensemble",
    group: "classical_vocals",
    uses_epochs: true
  )

  insert(:category,
    name: "Zupf-Ensemble",
    short_name: "ZupfEns",
    genre: "classical",
    type: "ensemble",
    group: "plucked",
    uses_epochs: true
  )

  insert(:category,
    name: "Drumset (Pop) solo",
    short_name: "PopDrums",
    genre: "popular",
    type: "solo",
    group: "pop_instrumental",
    uses_epochs: false
  )

  insert(:category,
    name: "E-Bass (Pop) solo",
    short_name: "PopBass",
    genre: "popular",
    type: "solo",
    group: "pop_instrumental",
    uses_epochs: false
  )

  insert(:category,
    name: "Gesang (Pop) solo",
    short_name: "PopGesang",
    genre: "popular",
    type: "solo",
    group: "pop_vocals",
    uses_epochs: false
  )

  insert(:category,
    name: "Gitarre (Pop) solo",
    short_name: "PopGitarre",
    genre: "popular",
    type: "solo",
    group: "pop_instrumental",
    uses_epochs: false
  )

  insert(:category,
    name: "Instrumental-Solo (Pop)",
    short_name: "PopInstr",
    genre: "popular",
    type: "solo",
    group: "pop_instrumental",
    uses_epochs: false
  )

  insert(:category,
    name: "Musical",
    short_name: "Musical",
    genre: "popular",
    type: "solo",
    group: "pop_vocals",
    uses_epochs: false
  )

  insert(:category,
    name: "Vokal-Ensemble (Pop)",
    short_name: "PopVokalEns",
    genre: "popular",
    type: "ensemble",
    group: "pop_vocals",
    uses_epochs: false
  )
end)
