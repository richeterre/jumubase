defmodule Jumubase.Foundation.ContestSeed do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{ContestCategory, ContestSeed}

  @primary_key false

  embedded_schema do
    field :season, :integer, default: nil
    field :round, :integer, default: nil

    embeds_many :contest_categories, ContestCategory
  end

  @required_attrs [:season, :round]

  @doc false
  def changeset(%ContestSeed{} = contest_seed, params) do
    contest_seed
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_number(:season, greater_than: 0)
    |> validate_inclusion(:round, JumuParams.rounds())
    |> cast_embed(:contest_categories, required: true)
  end
end
