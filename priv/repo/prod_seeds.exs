import Jumubase.Factory
alias Jumubase.Repo

Repo.transaction fn ->
  # Create hosts

  insert(:host, id: 17, name: "DS Bratislava",
    address: "c/o [Marianna Gazdíková & Astrid Rajter](mailto:jumu@deutscheschule.sk)<br>Palisády 51<br>811 06 Bratislava<br>Slowakei",
    city: "Bratislava", country_code: "SK", time_zone: "Europe/Bratislava", latitude: 48.1491521, longitude: 17.103554
  )
  insert(:host, id: 18, name: "DS Brüssel",
    address: "c/o Konstanze Rommel<br>Lange Eikstraat 71<br>1970 Wezembeek-Oppem<br>Belgien",
    city: "Brüssel", country_code: "BE", time_zone: "Europe/Brussels", latitude: 50.8519895, longitude: 4.4926787
  )
  insert(:host, id: 15, name: "DS Budapest",
    address: "c/o [Peter Bachmaier](mailto:pbachmaier@deutscheschule.hu)<br>Cinege ut 8/c<br>1121 Budapest<br>Ungarn",
    city: "Budapest", country_code: "HU", time_zone: "Europe/Budapest", latitude: 47.51, longitude: 18.983813
  )
  insert(:host, id: 7, name: "DS Dublin",
    address: "c/o [Noelle Brennan](mailto:noelle.brennan@kilians.com)<br>Roebuck Road<br>Clonskeagh, Dublin 14<br>Irland",
    city: "Dublin", country_code: "IE", time_zone: "Europe/Dublin", latitude: 53.303453, longitude: -6.2293214
  )
  insert(:host, id: 13, name: "DS Genf",
    address: "c/o Elinor Ziellenbach<br>6, Chemin de Champ-Claude<br>1214 Vernier<br>Schweiz",
    city: "Genf", country_code: "CH", time_zone: "Europe/Zurich", latitude: 46.2181677, longitude: 6.0874632
  )
  insert(:host, id: 4, name: "DS Helsinki",
    address: "c/o [Robert Bär](mailto:robert.bar@dsh.fi)<br>Malminkatu 14<br>00100 Helsinki<br>Finnland",
    city: "Helsinki", country_code: "FI", time_zone: "Europe/Helsinki", latitude: 60.167165, longitude: 24.93205
  )
  insert(:host, id: 2, name: "DS Kopenhagen",
    address: "c/o [Angelika Bowes](mailto:ak@adm.sanktpetriskole.dk)<br>Larslejsstræde 5-7<br>1451 København K<br>Dänemark",
    city: "Kopenhagen", country_code: "DK", time_zone: "Europe/Copenhagen", latitude: 55.6800835, longitude: 12.5695033
  )
  insert(:host, id: 16, name: "DS London",
    address: "c/o [Evelyn Meyer](mailto:evelyn.meyer@dslondon.org.uk)<br>Douglas House, Petersham Road<br>Richmond/Surrey TW 10 7 AH<br>Vereinigtes Königreich",
    city: "London", country_code: "GB", time_zone: "Europe/London", latitude: 51.4451339, longitude: -0.3050807
  )
  insert(:host, id: 11, name: "DS Moskau",
    address: "c/o [Christiane Beiküfner](mailto:bei@dsmoskau.ru)<br>Prospekt Wernadskogo 103/5<br>119526 Moskau<br>Russland",
    city: "Moskau", country_code: "RU", time_zone: "Europe/Moscow", latitude: 55.6643808, longitude: 37.4953562
  )
  insert(:host, id: 8, name: "DS Oslo",
    address: "c/o [Katja Maiwald](mailto:katja.maiwald@deutsche-schule.no)<br>Sporveisgata 20<br>0354 Oslo<br>Norwegen",
    city: "Oslo", country_code: "NO", time_zone: "Europe/Oslo", latitude: 59.9249933, longitude: 10.7251024
  )
  insert(:host, id: 5, name: "DS Paris",
    address: "c/o [Martina Freund](mailto:martina.freund-krueger@idsp.fr)<br>Rue Pasteur 18<br>92 210 Saint Cloud<br>Frankreich",
    city: "Paris", country_code: "FR", time_zone: "Europe/Paris", latitude: 48.8423042, longitude: 2.2035179
  )
  insert(:host, id: 14, name: "DS Prag",
    address: "c/o Aleš Kudela<br>Schwarzenberská 1/700<br>15800 Praha 5<br>Tschechische Republik",
    city: "Prag", country_code: "CZ", time_zone: "Europe/Prague", latitude: 50.0556074, longitude: 14.3541417
  )
  insert(:host, id: 1, name: "DS Sofia",
    address: "c/o Tiko Barz<br>ul. Joliot Curie 25<br>1113 Sofia<br>Bulgarien",
    city: "Sofia", country_code: "BG", time_zone: "Europe/Sofia", latitude: 42.6691648, longitude: 23.3492821
  )
  insert(:host, id: 12, name: "DS Stockholm",
    address: "c/o [Irene Rieck](mailto:irene.rieck@tyskaskolan.se)<br>Karlavägen 25<br>11431 Stockholm<br>Schweden",
    city: "Stockholm", country_code: "SE", time_zone: "Europe/Stockholm", latitude: 59.3422421, longitude: 18.0699085
  )
  insert(:host, id: 9, name: "DS Warschau",
    address: "c/o [Marcin Lemiszewski](mailto:m.lemiszewski@wbs.pl)<br>ul. Sw. Urszuli Ledóchowskiej 3<br>02-972 Warszawa (Wilanów)<br>Polen",
    city: "Warschau", country_code: "PL", time_zone: "Europe/Warsaw", latitude: 52.1577924, longitude: 21.0691116
  )

  # Create categories

  insert(:category, id: 1, name: "\"Kinder musizieren\"", short_name: "Kimu", genre: "kimu", type: "solo_or_ensemble")

  insert(:category, id: 6, name: "Akkordeon solo", short_name: "Akkordeon", genre: "classical", type: "solo")
  insert(:category, id: 27, name: "Blockflöte solo", short_name: "Blockflöte", genre: "classical", type: "solo")
  insert(:category, id: 32, name: "Fagott solo", short_name: "Fagott", genre: "classical", type: "solo")
  insert(:category, id: 21, name: "Gesang solo", short_name: "Gesang", genre: "classical", type: "solo")
  insert(:category, id: 38, name: "Gitarre solo", short_name: "Gitarre", genre: "classical", type: "solo")
  insert(:category, id: 20, name: "Harfe solo", short_name: "Harfe", genre: "classical", type: "solo")
  insert(:category, id: 33, name: "Horn solo", short_name: "Horn", genre: "classical", type: "solo")
  insert(:category, id: 50, name: "Kantele solo", short_name: "Kantele", genre: "classical", type: "solo")
  insert(:category, id: 30, name: "Klarinette solo", short_name: "Klarinette", genre: "classical", type: "solo")
  insert(:category, id: 19, name: "Klavier solo", short_name: "Klavier", genre: "classical", type: "solo")
  insert(:category, id: 5, name: "Kontrabass solo", short_name: "Kontrabass", genre: "classical", type: "solo")
  insert(:category, id: 8, name: "Mallets solo", short_name: "Mallets", genre: "classical", type: "solo")
  insert(:category, id: 40, name: "Mandoline solo", short_name: "Mandoline", genre: "classical", type: "solo")
  insert(:category, id: 29, name: "Oboe solo", short_name: "Oboe", genre: "classical", type: "solo")
  insert(:category, id: 42, name: "Orgel solo", short_name: "Orgel", genre: "classical", type: "solo")
  insert(:category, id: 7, name: "Percussion solo", short_name: "Percussion", genre: "classical", type: "solo")
  insert(:category, id: 35, name: "Posaune solo", short_name: "Posaune", genre: "classical", type: "solo")
  insert(:category, id: 28, name: "Querflöte solo", short_name: "Querflöte", genre: "classical", type: "solo")
  insert(:category, id: 31, name: "Saxophon solo", short_name: "Saxophon", genre: "classical", type: "solo")
  insert(:category, id: 36, name: "Tenorhorn/Bariton/Euphonium solo", short_name: "ThBarEuph", genre: "classical", type: "solo")
  insert(:category, id: 34, name: "Trompete/Flügelhorn solo", short_name: "Trompete", genre: "classical", type: "solo")
  insert(:category, id: 37, name: "Tuba solo", short_name: "Tuba", genre: "classical", type: "solo")
  insert(:category, id: 3, name: "Viola solo", short_name: "Viola", genre: "classical", type: "solo")
  insert(:category, id: 2, name: "Violine solo", short_name: "Violine", genre: "classical", type: "solo")
  insert(:category, id: 4, name: "Violoncello solo", short_name: "Cello", genre: "classical", type: "solo")
  insert(:category, id: 39, name: "Zither solo", short_name: "Zither", genre: "classical", type: "solo")

  insert(:category, id: 24, name: "Akkordeon-Kammermusik", short_name: "AkkKammer", genre: "classical", type: "ensemble")
  insert(:category, id: 14, name: "Besondere Ensembles: Alte Musik", short_name: "BesEnsAlteMusik", genre: "classical", type: "ensemble")
  insert(:category, id: 47, name: "Besondere Ensembles: Klassik, Romantik, Spätromantik & Klassische Moderne", short_name: "BesEnsKlassik", genre: "classical", type: "ensemble")
  insert(:category, id: 23, name: "Bläser-Ensemble", short_name: "BläserEns", genre: "classical", type: "ensemble")
  insert(:category, id: 9, name: "Duo: Klavier & Blasinstrument", short_name: "Klavier+Bläser", genre: "classical", type: "ensemble")
  insert(:category, id: 44, name: "Duo: Klavier & Streichinstrument", short_name: "Klavier+Streicher", genre: "classical", type: "ensemble")
  insert(:category, id: 45, name: "Duo Kunstlied", short_name: "Kunstlied", genre: "classical", type: "ensemble")
  insert(:category, id: 13, name: "Harfen-Ensemble", short_name: "HarfenEns", genre: "classical", type: "ensemble")
  insert(:category, id: 10, name: "Klavier-Kammermusik", short_name: "KlavierKammer", genre: "classical", type: "ensemble")
  insert(:category, id: 43, name: "Klavier vierhändig", short_name: "Klavier4H", genre: "classical", type: "ensemble")
  insert(:category, id: 25, name: "Neue Musik", short_name: "NeueMusik", genre: "classical", type: "ensemble")
  insert(:category, id: 46, name: "Schlagzeug-Ensemble", short_name: "SchlagzEns", genre: "classical", type: "ensemble")
  insert(:category, id: 22, name: "Streicher-Ensemble", short_name: "StreicherEns", genre: "classical", type: "ensemble")
  insert(:category, id: 11, name: "Vokal-Ensemble", short_name: "VokalEns", genre: "classical", type: "ensemble")
  insert(:category, id: 12, name: "Zupf-Ensemble", short_name: "ZupfEns", genre: "classical", type: "ensemble")

  insert(:category, id: 18, name: "Drumset (Pop) solo", short_name: "PopDrums", genre: "popular", type: "solo")
  insert(:category, id: 17, name: "E-Bass (Pop) solo", short_name: "PopBass", genre: "popular", type: "solo")
  insert(:category, id: 15, name: "Gesang (Pop) solo", short_name: "PopGesang", genre: "popular", type: "solo")
  insert(:category, id: 16, name: "Gitarre (Pop) solo", short_name: "PopGitarre", genre: "popular", type: "solo")
  insert(:category, id: 49, name: "Instrumental-Solo (Pop)", short_name: "PopInstr", genre: "popular", type: "solo")
  insert(:category, id: 41, name: "Musical", short_name: "Musical", genre: "popular", type: "solo")

  insert(:category, id: 26, name: "Vokal-Ensemble (Pop)", short_name: "PopVokalEns", genre: "popular", type: "ensemble")
end
