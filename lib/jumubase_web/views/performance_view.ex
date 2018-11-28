defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import Ecto.Changeset
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest}

  @doc """
  Renders JS that powers the registration form.
  """
  def render("scripts.new.html", assigns) do
    render_registration_script(assigns)
  end

  def render("scripts.edit.html", assigns) do
    render_registration_script(assigns)
  end

  # Private helpers

  defp render_registration_script(assigns) do
    %{
      conn: conn,
      contest: contest,
      changeset: changeset,
    } = assigns

    json = render_html_safe_json(
      %{
        changeset: changeset |> remove_obsolete_associations,
        params: conn.params["performance"],
        contest_category_options: (
          for {name, id, type, genre} <- cc_options(contest) do
            %{id: id, name: name, type: type, genre: genre}
          end
        ),
        birthdate_year_options: birthdate_year_options(contest.season),
        birthdate_month_options: birthdate_month_options(),
        role_options: role_options(),
        instrument_options: instrument_options(),
        epoch_options: epoch_options(),
        vocabulary: %{
          participant: gettext("Participant"),
          piece: gettext("Piece"),
          roles: %{
            soloist: gettext("Soloist"),
            ensemblist: gettext("Ensemblist"),
            accompanist: gettext("Accompanist")
          }
        }
      }
    )

    ~E{
      <script src="/js/registration.js"></script>
      <script>registrationForm(<%= raw(json) %>)</script>
    }
  end

  # Excludes nested association changesets bound for deletion or replacement.
  defp remove_obsolete_associations(changeset) do
    changeset
    |> update_change(:appearances, &exclude_obsolete/1)
    |> update_change(:pieces, &exclude_obsolete/1)
  end

  defp exclude_obsolete(changesets) do
    Enum.filter(changesets, &(&1.action in [:insert, :update]))
  end

  defp cc_options(%Contest{} = contest) do
    Foundation.load_contest_categories(contest)
    |> Map.get(:contest_categories)
    |> Enum.map(&{&1.category.name, &1.id, &1.category.type, &1.category.genre})
  end

  defp birthdate_year_options(season) do
    AgeGroups.birthyear_range(season)
  end

  defp birthdate_month_options() do
    Timex.Translator.current_locale
    |> Timex.Translator.get_months
    |> Map.to_list
    |> Enum.map(fn {ordinal, name} ->
      %{value: Integer.to_string(ordinal), label: name}
    end)
  end

  defp role_options do
    Enum.map(JumuParams.participant_roles, fn
      role -> %{id: role, label: role_name(role)}
    end)
  end

  defp role_name(role) do
    case role do
      "soloist" -> gettext("Soloist")
      "accompanist" -> gettext("Accompanist")
      "ensemblist" -> gettext("Ensemblist")
    end
  end

  defp instrument_options do
    Jumubase.Showtime.Instruments.all
    |> Enum.sort_by(fn {_value, label} -> label end)
    |> Enum.map(fn {value, label} -> %{value: value, label: label} end)
  end

  defp epoch_options do
    Enum.map(JumuParams.epochs, fn epoch ->
      %{id: epoch, label: "#{epoch}) #{JumuParams.epoch_description(epoch)}"}
    end)
  end
end
