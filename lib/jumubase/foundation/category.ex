defmodule Jumubase.Foundation.Category do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Category

  schema "categories" do
    field :name, :string
    field :short_name, :string
    field :genre, :string
    field :type, :string
    field :group, :string

    timestamps()
  end

  @required_attrs [:name, :short_name, :genre, :type, :group]

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:genre, JumuParams.genres)
    |> validate_inclusion(:type, JumuParams.category_types)
    |> validate_inclusion(:group, JumuParams.category_groups)
  end
end
