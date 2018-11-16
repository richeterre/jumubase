defmodule Jumubase.Foundation.Host do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.Host

  schema "hosts" do
    field :name, :string
    field :address, :string
    field :city, :string
    field :country_code, :string
    field :time_zone, :string
    field :latitude, :float
    field :longitude, :float

    many_to_many :users, User, join_through: "hosts_users"

    timestamps()
  end

  @required_attrs [:name, :address, :city, :country_code, :time_zone, :latitude, :longitude]

  @doc false
  def changeset(%Host{} = host, attrs) do
    host
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
