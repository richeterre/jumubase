defmodule Jumubase.Foundation.ContestCategory do
  use Jumubase.Schema
  alias Jumubase.Foundation.{Category, Contest}
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
end
