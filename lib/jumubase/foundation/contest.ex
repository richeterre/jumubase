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
    field :name_suffix, :string
    field :deadline, :date
    field :start_date, :date
    field :end_date, :date
    field :certificate_date, :date
    field :dates_verified, :boolean, read_after_writes: true
    field :allows_registration, :boolean, read_after_writes: true
    field :timetables_public, :boolean, read_after_writes: true

    belongs_to :host, Host
    has_many :contest_categories, ContestCategory

    timestamps()
  end

  @doc """
  Allows changing all editable fields of a contest, e.g. via an admin interface.
  """
  def changeset(%Contest{} = contest, attrs) do
    required_attrs = [:season, :round, :host_id, :grouping, :deadline, :start_date, :end_date]

    optional_attrs = [
      :name_suffix,
      :certificate_date,
      :dates_verified,
      :allows_registration,
      :timetables_public
    ]

    contest
    |> cast(attrs, required_attrs ++ optional_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:season, greater_than: 0)
    |> validate_inclusion(:round, JumuParams.rounds())
    |> validate_inclusion(:grouping, JumuParams.groupings())
    |> validate_dates()
    |> sanitize_text_input()
  end

  @doc """
  Allows filling/confirming crucial contest fields that initially received placeholder values.
  """
  def preparation_changeset(%Contest{} = contest, attrs) do
    required_attrs = [:deadline, :start_date, :end_date]

    contest
    |> cast(attrs, required_attrs ++ [:certificate_date])
    |> validate_required(required_attrs)
    |> validate_dates()
    |> maybe_mark_dates_as_verified()
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

  defp sanitize_text_input(%Changeset{} = changeset) do
    changeset
    |> update_change(:name_suffix, fn
      suffix when is_binary(suffix) -> String.trim(suffix)
      suffix -> suffix
    end)
  end

  defp maybe_mark_dates_as_verified(%Changeset{} = changeset) do
    if changeset.valid? do
      put_change(changeset, :dates_verified, true)
    else
      changeset
    end
  end
end
