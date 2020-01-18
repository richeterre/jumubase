# Jumubase

Jumubase is a tool for organizers of Germany's largest youth music competition – [Jugend musiziert][jugend-musiziert], or "Jumu" in short. The software powers [jumu-weltweit.org][jumu-weltweit], a competition hub for German schools across Europe.

The application serves two main audiences:

- Jumu **participants** and their families, friends and teachers; they can sign up for a contest, edit their information, and check schedules and results **without a user account.**
- Jumu **organizers** on both local and global level, who can manage contest data, enter results and print contest-related material. The permissions for this are granted via **personal user accounts.**

Jumubase also exposes some public data, such as timetables and results, via a JSON API that serves mobile clients for [Android][jumu-nordost-react-native] and [iOS][jumu-nordost-ios].

[jugend-musiziert]: https://en.wikipedia.org/wiki/Jugend_musiziert
[jumu-weltweit]: http://www.jumu-weltweit.org
[jumu-nordost-react-native]: https://github.com/richeterre/jumu-nordost-react-native
[jumu-nordost-ios]: https://github.com/richeterre/jumu-nordost-ios

## Setup instructions

Jumubase is built with [Elixir][elixir] and the [Phoenix framework][phoenix-framework]. Follow these steps to set up a local environment:

0. Clone this codebase
1. [Install Elixir][elixir-installation]
1. Install PostgreSQL, e.g. through the provided `docker-compose.yml` file or [Postgres.app][postgres-app]
1. Install dependencies with `mix deps.get`
1. Install JS dependencies with `cd assets && npm install`
1. Create, migrate and seed the local database with `mix ecto.setup`
1. Start Phoenix endpoint with `mix phx.server`

Then, point your browser to [`localhost:4000`][localhost].

[elixir]: https://www.elixir-lang.org
[phoenix-framework]: https://phoenixframework.org
[elixir-installation]: https://elixir-lang.org/install.html
[postgres-app]: https://postgresapp.com
[localhost]: http://localhost:4000

## Release instructions

Ensure the following environment variables are made available to the app:

- `DATABASE_URL` – Set automatically e.g. on Heroku when provisioning a database.
- `POOL_SIZE` – Depends on how many database connections are allowed by the plan. Leave some room for occasional one-off `mix` tasks such as migrations.
- `SECRET_KEY_BASE` – Can be generated using `mix phx.gen.secret`.
- `PHAUXTH_TOKEN_SALT` – Can be generated in IEx using `Phauxth.Config.gen_token_salt`.

## Documentation

### Domain vocabulary

Many schemas / data structs in this app are inextricably linked with the "Jugend musiziert" competition. The following list serves as a brief explanation to those unfamiliar with the domain:

**User**<br />
A user of the software, [identified](#authentication) by their email and password.

**Host**<br />
An institution, typically a school, that can host contests. Each host belongs to a grouping, whose local contests lead to a single 2nd-round contest. Hosts can change grouping between seasons, in which case their historical contests stay with the original grouping.

**Stage**<br />
A location where performances take place. Every host has at least one, but often several stages.

**Contest**<br />
A single- or multi-day event during which performances take place. Besides its associated host, it includes a _season_ (= competition year) and a _round_.

**Category**<br />
A set of constraints for participating in a contest. Each category is designed either for solo or ensemble performances and mandates what pieces can be performed, as well as a min/max duration that depends on the performance's age group.

**Contest category**<br />
A manifestation of a category when offered within a particular contest. This schema exists to hold additional constraints: Some contests might offer a category only for certain age groups, or not at all.

**Performance**<br />
A musical entry taking place within a contest category, at a given time and venue. It is associated with an age group calculated from the birth dates of the soloist or ensemblists (but not accompanists).

**Appearance**<br />
A single participant's contribution to a performance. It holds the participant's instrument and role (i.e. soloist, ensemblist or accompanist, the first two being mutually exclusive). It also stores its own age group, which for accompanists can differ from the performance's age group. Each appearance is awarded points by the jury, and a certificate is given to its participant afterwards.

**Participant**<br />
A person appearing in one or more performances within a contest.

**Piece**<br />
A piece of music presented during a performance. It holds information on the composer or original artist, as well as a musical epoch.

### Parameters

Some Jumu-related data (such as rounds, roles, genres, and category types) is unlikely to change much over time and therefore hard-coded into the `JumuParams` module. Parameters that are likely to change, or not meant for the public eye, are stored as environment variables instead.

### Authentication

[Phauxth][phauxth] is used for user authentication. Users can be associated with one or several hosts, typically for the reason of being employed there and acting as local organizers. They can only manipulate resources "belonging" to those hosts.

Each user has a role assigned to them:

- **Local organizers** may access only contests of their associated hosts
- **Global organizers** may access contests in their associated hosts' current groupings
- **Inspectors** get read-only access to data for statistical purposes
- **Admin** users have full privileges

[phauxth]: https://github.com/riverrun/phauxth

## License

Jumubase is published under the [MIT License][mit-license].

[mit-license]: https://opensource.org/licenses/MIT
