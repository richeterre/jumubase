defmodule Jumubase.Foundation.Host do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.Foundation.Host

  schema "hosts" do
    field :city, :string
    field :country_code, :string
    field :name, :string
    field :time_zone, :string

    timestamps()
  end

  @required_attrs [:name, :city, :country_code, :time_zone]

  @doc false
  def changeset(%Host{} = host, attrs) do
    host
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
