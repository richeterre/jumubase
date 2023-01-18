defmodule Jumubase.Foundation.Category do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Category

  schema "categories" do
    field :name, :string
    field :short_name, :string
    field :type, :string
    field :genre, :string
    field :group, :string
    field :uses_epochs, :boolean, read_after_writes: true
    field :bw_code, :string
    field :notes, :string

    timestamps()
  end

  @required_attrs [:name, :short_name, :type, :genre, :group, :uses_epochs]
  @optional_attrs [:bw_code, :notes]

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:type, JumuParams.category_types())
    |> validate_inclusion(:genre, JumuParams.genres())
    |> validate_inclusion(:group, JumuParams.category_groups())
  end
end
