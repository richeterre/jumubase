defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.AgeGroups

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
      contest: contest,
      changeset: changeset,
      contest_category_options: cc_options,
    } = assigns

    json = render_html_safe_json(
      %{
        changeset: changeset,
        contest_category_options: (
          for {name, id, type} <- cc_options do
            %{id: id, name: name, type: type}
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
    |> Enum.map(fn {value, label} -> %{value: value, label: label} end)
  end

  defp epoch_options do
    Enum.map(JumuParams.epochs, fn epoch ->
      %{id: epoch, label: "#{epoch}) #{JumuParams.epoch_description(epoch)}"}
    end)
  end
end
