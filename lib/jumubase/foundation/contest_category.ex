defmodule Jumubase.Foundation.ContestCategory do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.Foundation.AgeGroups
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

  @required_attrs [:contest_id, :category_id, :min_age_group, :max_age_group]

  @optional_attrs [:min_advancing_age_group, :max_advancing_age_group]

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:min_age_group, AgeGroups.all)
    |> validate_inclusion(:max_age_group, AgeGroups.all)
    |> validate_inclusion(:min_advancing_age_group, AgeGroups.all)
    |> validate_inclusion(:max_advancing_age_group, AgeGroups.all)
  end
end
