defmodule Jumubase.Foundation.ContestCategory do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Jumubase.Foundation.AgeGroups
  alias Jumubase.Foundation.{Category, Contest, ContestCategory}
  alias Jumubase.Showtime.Performance

  schema "contest_categories" do
    field :min_age_group, :string
    field :max_age_group, :string
    field :min_advancing_age_group, :string
    field :max_advancing_age_group, :string
    field :allows_wespe_nominations, :boolean, read_after_writes: true
    field :groups_accompanists, :boolean, read_after_writes: true

    belongs_to :contest, Contest
    belongs_to :category, Category
    has_many :performances, Performance

    timestamps()
  end

  @required_attrs [
    :category_id,
    :min_age_group,
    :max_age_group,
    :allows_wespe_nominations,
    :groups_accompanists
  ]
  @optional_attrs [:min_advancing_age_group, :max_advancing_age_group]

  @doc false
  def changeset(%ContestCategory{} = contest_category, attrs) do
    contest_category
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:min_age_group, AgeGroups.all())
    |> validate_inclusion(:max_age_group, AgeGroups.all())
    |> validate_inclusion(:min_advancing_age_group, AgeGroups.all())
    |> validate_inclusion(:max_advancing_age_group, AgeGroups.all())
  end
end
