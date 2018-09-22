defmodule Jumubase.Foundation.Contest do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{Contest, ContestCategory, Host}

  schema "contests" do
    field :season, :integer
    field :round, :integer
    field :start_date, :date
    field :end_date, :date
    field :deadline, :date

    belongs_to :host, Host
    has_many :contest_categories, ContestCategory

    timestamps()
  end

  @required_attrs [:season, :round, :start_date, :end_date, :deadline]

  @doc false
  def changeset(%Contest{} = contest, attrs) do
    contest
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_number(:season, greater_than: 0)
    |> validate_inclusion(:round, JumuParams.rounds)
    |> validate_dates
  end

  # Private helpers

  defp validate_dates(%Changeset{} = changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    deadline = get_field(changeset, :deadline)

    cond do
      !start_date || !end_date || !deadline ->
        changeset
      Timex.before?(end_date, start_date) ->
        add_error(changeset, :end_date, dgettext("errors", "can't be before the start date"))
      not Timex.before?(deadline, start_date) ->
        add_error(changeset, :deadline, dgettext("errors", "must be before the start date"))
      true ->
        changeset
    end
  end
end
