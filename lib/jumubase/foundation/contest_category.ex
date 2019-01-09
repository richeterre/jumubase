defmodule Jumubase.Foundation.ContestCategory do
  use Jumubase.Schema
  alias Jumubase.Foundation.{Category, Contest}

  schema "contest_categories" do
    field :min_age_group, :string
    field :max_age_group, :string
    field :min_advancing_age_group, :string
    field :max_advancing_age_group, :string

    belongs_to :contest, Contest
    belongs_to :category, Category
    has_many :performances, Jumubase.Showtime.Performance

    timestamps()
  end
end
