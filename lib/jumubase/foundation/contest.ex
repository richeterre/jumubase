defmodule Jumubase.Foundation.Contest do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{Contest, ContestCategory, Host}

  schema "contests" do
    field :season, :integer
    field :round, :integer
    field :deadline, :date
    field :start_date, :date
    field :end_date, :date
    field :certificate_date, :date
    field :timetables_public, :boolean, read_after_writes: true

    belongs_to :host, Host
    has_many :contest_categories, ContestCategory

    timestamps()
  end

  @required_attrs [:season, :round, :deadline, :start_date, :end_date]
  @optional_attrs [:certificate_date, :timetables_public]

  @doc false
  def changeset(%Contest{} = contest, attrs) do
    contest
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_number(:season, greater_than: 0)
    |> validate_inclusion(:round, JumuParams.rounds())
    |> validate_dates
  end

  @doc """
  Returns whether the contest's deadline has passed on the given date.
  """
  def deadline_passed?(%Contest{deadline: deadline}, %Date{} = date) do
    Timex.before?(deadline, date)
  end

  # Private helpers

  defp validate_dates(%Changeset{} = changeset) do
    deadline = get_field(changeset, :deadline)
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    certificate_date = get_field(changeset, :certificate_date)

    cond do
      !start_date || !end_date || !deadline ->
        changeset

      Timex.before?(end_date, start_date) ->
        add_error(changeset, :end_date, dgettext("errors", "can't be before the start date"))

      not Timex.before?(deadline, start_date) ->
        add_error(changeset, :deadline, dgettext("errors", "must be before the start date"))

      !!certificate_date and Timex.before?(certificate_date, end_date) ->
        add_error(
          changeset,
          :certificate_date,
          dgettext("errors", "can't be before the end date")
        )

      true ->
        changeset
    end
  end
end
