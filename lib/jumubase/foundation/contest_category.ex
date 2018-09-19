defmodule Jumubase.Foundation.ContestCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{Category, Contest}

  schema "contest_categories" do
    field :min_age_group, :string
    field :max_age_group, :string
    field :min_advancing_age_group, :string
    field :max_advancing_age_group, :string
    belongs_to :contest, Contest
    belongs_to :category, Category

    timestamps()
  end

  @required_attrs [:contest_id, :category_id, :min_age_group,
    :max_age_group, :min_advancing_age_group, :max_advancing_age_group]

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:min_age_group, JumuParams.age_groups)
    |> validate_inclusion(:max_age_group, JumuParams.age_groups)
    |> validate_inclusion(:min_advancing_age_group, JumuParams.age_groups)
    |> validate_inclusion(:max_advancing_age_group, JumuParams.age_groups)
  end
end