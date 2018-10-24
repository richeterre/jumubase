Jumubase
========

Jumubase is a tool for organizers of Germany's largest youth music competition – [Jugend musiziert][jugend-musiziert], or "Jumu" in short. The software will soon power [jumu-weltweit.org][jumu-weltweit], a competition hub for German schools around the world.

The application serves two main audiences:

* Jumu __participants__ and their families, friends and teachers; they can sign up for a contest, edit their information, and check schedules and results __without a user account.__
* Jumu __organizers__ on both local and global level, who can manage contest data, enter results and print contest-related material. The permissions for this are granted via __personal user accounts.__

Jumubase will also expose some of its public data via a JSON API that serves mobile clients for [Android][jumu-nordost-react-native] and [iOS][jumu-nordost-ios].

[jugend-musiziert]: https://en.wikipedia.org/wiki/Jugend_musiziert
[jumu-weltweit]: http://www.jumu-weltweit.org
[jumu-nordost-react-native]: https://github.com/richeterre/jumu-nordost-react-native
[jumu-nordost-ios]: https://github.com/richeterre/jumu-nordost-ios

## Setup instructions

0. Clone this codebase
0. Install PostgreSQL, e.g. through the provided `docker-compose.yml` file or [Postgres.app][postgres-app]
0. Install dependencies with `mix deps.get`
0. Install JS dependencies with `cd assets && npm install`
0. Create, migrate and seed the local database with `mix ecto.setup`
0. Start Phoenix endpoint with `mix phx.server`

Then, point your browser to [`localhost:4000`][localhost].

[postgres-app]: http://postgresapp.com
[localhost]: http://localhost:4000

## Release instructions

Ensure the following environment variables are made available to the app:

* `DATABASE_URL` – Set automatically e.g. on Heroku when provisioning a database.
* `POOL_SIZE` – Depends on how many database connections are allowed by the plan. Leave some room for occasional one-off `mix` tasks such as migrations.
* `SECRET_KEY_BASE` – Can be generated using `mix phx.gen.secret`.
* `PHAUXTH_TOKEN_SALT` – Can be generated in IEx using `Phauxth.Config.gen_token_salt`.

## Documentation

### Domain vocabulary

Many schemas / data structs in this app are inextricably linked with the "Jugend musiziert" competition. The following list serves as a brief explanation to those unfamiliar with the domain:

__User__<br />
A user of the software, [identified](#authentication) by their email and password.

__Host__<br />
An institution, typically a school, that can host contests.

__Contest__<br />
A single or multi-day event that forms the basic entity of Jugend musiziert. Besides its associated host, it includes a _season_ (= competition year) and a _round_.

__Category__<br />
A set of constraints for participating in a contest. Each categories is either for solo or ensemble performances and mandates what pieces can be performed, as well as a min/max duration that depends on the performance's age group.

__Contest category__<br />
A manifestation of a category when offered within a particular contest. This schema exists to hold additional constraints: Some contests might offer a category only for certain age groups, or not at all.

__Performance__<br />
A musical entry taking place within a contest category, at a given time and venue. It is associated with an age group calculated from the birth dates of the soloist or ensemblists (but not accompanists).

__Appearance__<br />
A single participant's contribution to a performance. It holds the participant's instrument and role (i.e. soloist, ensemblist or accompanist, the first two being mutually exclusive). It also stores its own age group, which for accompanists can differ from the performance's age group. Each appearance is awarded points by the jury, and a certificate is given to its participant afterwards.

__Participant__<br />
A person appearing in one or more performances within a contest.

__Piece__<br />
A piece of music presented during a performance. It holds information on the composer or original artist, as well as a musical epoch.

### Parameters

Some Jumu-related data (such as rounds, roles, genres, and category types) is unlikely to change much over time and therefore hard-coded into the `JumuParams` module.

### Authentication

[Phauxth][phauxth] is used for user authentication. Users can be associated with one or several hosts, typically for the reason of being employed there and acting as local organizers. They can only manipulate resources "belonging" to those hosts.

Apart from __local organizers__ with their host-based access rights, there are __global organizers__ who organize the 2nd round hosted somewhere abroad in round-robin fashion, __inspectors__ who may access certain data for statistical purposes, and __admin__ users with full privileges.

[phauxth]: https://github.com/riverrun/phauxth

## License

Jumubase is published under the [MIT License][mit-license].

[mit-license]: https://opensource.org/licenses/MIT
