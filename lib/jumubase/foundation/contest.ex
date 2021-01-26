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
    field :grouping, :string
    field :deadline, :date
    field :start_date, :date
    field :end_date, :date
    field :certificate_date, :date
    field :allows_registration, :boolean, read_after_writes: true
    field :timetables_public, :boolean, read_after_writes: true

    belongs_to :host, Host
    has_many :contest_categories, ContestCategory

    timestamps()
  end

  @required_attrs [:season, :round, :host_id, :grouping, :deadline, :start_date, :end_date]
  @optional_attrs [:certificate_date, :allows_registration, :timetables_public]

  @doc false
  def changeset(%Contest{} = contest, attrs) do
    contest
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_number(:season, greater_than: 0)
    |> validate_inclusion(:round, JumuParams.rounds())
    |> validate_inclusion(:grouping, JumuParams.groupings())
    |> validate_dates()
    |> handle_lw_uniqueness()
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

  defp handle_lw_uniqueness(%Changeset{} = changeset) do
    unique_constraint(changeset, :contest,
      name: :one_lw_per_season_and_grouping,
      message: dgettext("errors", "has a round that's already taken for this year and grouping")
    )
  end
end
