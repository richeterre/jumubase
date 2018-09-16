defmodule Jumubase.Foundation.Contest do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{Contest, Host}

  schema "contests" do
    field :season, :integer
    field :round, :integer
    field :start_date, Timex.Ecto.Date
    field :end_date, Timex.Ecto.Date
    field :signup_deadline, Timex.Ecto.Date

    belongs_to :host, Host
    has_many :contest_categories, ContestCategory

    timestamps()
  end

  @required_attrs [:season, :round, :start_date, :end_date, :signup_deadline]

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
    signup_deadline = get_field(changeset, :signup_deadline)

    cond do
      !start_date || !end_date || !signup_deadline ->
        changeset
      Timex.before?(end_date, start_date) ->
        add_error(changeset, :end_date, dgettext("errors", "can't be before the start date"))
      not Timex.before?(signup_deadline, start_date) ->
        add_error(changeset, :signup_deadline, dgettext("errors", "must be before the start date"))
      true ->
        changeset
    end
  end
end
