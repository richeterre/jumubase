alias Ecto.Changeset
alias Jumubase.Repo
alias Jumubase.Accounts.User
alias Jumubase.Foundation.Host

Repo.transaction fn ->
  # Clear existing data
  Repo.delete_all(Host)
  Repo.delete_all(User)

  # Create demo hosts

  _host1 = Repo.insert!(%Host{name: "DS Helsinki", city: "Helsinki", country_code: "FI", time_zone: "Europe/Helsinki"})
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
    first_name: "Lukas",
    last_name: "Landeswetter",
    email: "global-org@example.org",
    password: "password",
    role: "global-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host2])
  |> Repo.insert!

  User.create_changeset(%User{}, %{
    first_name: "Rieke",
    last_name: "Regionalwetter",
    email: "local-org@example.org",
    password: "password",
    role: "local-organizer"
  })
  |> Changeset.put_assoc(:hosts, [host3])
  |> Repo.insert!

  User.create_changeset(%User{}, %{
    first_name: "Ivo",
    last_name: "Inspektor",
    email: "inspektor@example.org",
    password: "password",
    role: "inspector"
  })
  |> Repo.insert!

  # Confirm all users
  Repo.update_all(User, set: [confirmed_at: DateTime.utc_now()])
end
