defmodule Jumubase.Foundation.Host do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation.{Contest, Host, Stage}

  schema "hosts" do
    field :name, :string
    field :current_grouping, :string
    field :address, :string
    field :city, :string
    field :country_code, :string
    field :time_zone, :string
    field :latitude, :float
    field :longitude, :float

    has_many :contests, Contest
    has_many :stages, Stage
    many_to_many :users, User, join_through: "hosts_users"

    timestamps()
  end

  @required_attrs [
    :name,
    :current_grouping,
    :address,
    :city,
    :country_code,
    :time_zone,
    :latitude,
    :longitude
  ]

  @doc false
  def changeset(%Host{} = host, attrs) do
    host
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:current_grouping, JumuParams.groupings())
  end
end
