defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import Ecto.Changeset
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{AgeGroups, Contest}
  alias Jumubase.Showtime.Participant

  @doc """
  Renders JS that powers the registration form.
  """
  def render("scripts.edit.html", assigns) do
    render_registration_script(assigns)
  end

  @doc """
  Returns the path to the contest's registration form, or nil if no contest is given.
  """
  def registration_path(conn, %Contest{} = c) do
    Routes.performance_path(conn, :new, c)
  end

  def registration_path(_conn, nil), do: nil

  @doc """
  Returns text that guides the user to a Kimu registration form with the given path.
  """
  def kimu_link(path) do
    gettext("for Kimu, there’s a %{form_link}",
      form_link: safe_to_string(link(gettext("separate form"), to: path))
    )
    |> raw
  end

  @doc """
  Returns predecessor host options based on the contest, suitable for a performance form.
  """
  def predecessor_host_options(%Contest{round: 2, grouping: grouping}) do
    Foundation.list_hosts_by_grouping(grouping)
    |> Enum.map(&{&1.name, &1.id})
  end

  def predecessor_host_options(%Contest{}), do: []

  def contest_category_options(%Contest{contest_categories: contest_categories}) do
    contest_categories |> Enum.map(&{&1.category.name, &1.id})
  end

  @doc """
  Returns a title for the registration form appearance panel,
  based on data found in the given appearance form.
  """
  def appearance_panel_title(%Phoenix.HTML.Form{index: index, source: changeset}) do
    fallback_title = gettext("Participant") <> " #{index + 1}"

    participant_name =
      case get_field(changeset, :participant) do
        %Participant{} = pt -> get_name(pt) || fallback_title
        _ -> fallback_title
      end

    case get_field(changeset, :role) do
      nil -> participant_name
      role -> participant_name <> " (#{role_title(role)})"
    end
  end

  defp get_name(%Participant{given_name: nil, family_name: nil}), do: nil
  defp get_name(%Participant{given_name: given_name, family_name: nil}), do: given_name
  defp get_name(%Participant{given_name: nil, family_name: family_name}), do: family_name
  defp get_name(%Participant{} = pt), do: full_name(pt)

  def piece_panel_title(%Changeset{} = cs, index) do
    fallback_title = gettext("Piece") <> " #{index + 1}"

    case get_field(cs, :title) do
      nil ->
        fallback_title

      title ->
        case {get_field(cs, :epoch), get_field(cs, :composer), get_field(cs, :artist)} do
          {"trad", _, _} -> "#{title} (trad.)"
          {_, nil, nil} -> title
          {_, nil, artist} -> "#{title} (#{artist})"
          {_, composer, nil} -> "#{title} (#{composer})"
        end
    end
  end

  def has_composer_fields?(performance_cs, contest, piece_cs) do
    get_field(piece_cs, :epoch) != "trad" and get_genre(performance_cs, contest) != "popular"
  end

  def has_artist_field?(performance_cs, contest, piece_cs) do
    get_field(piece_cs, :epoch) != "trad" and get_genre(performance_cs, contest) == "popular"
  end

  # Private helpers

  defp get_genre(performance_cs, contest) do
    cc_id = get_field(performance_cs, :contest_category_id)

    case Enum.find(contest.contest_categories, &(&1.id == cc_id)) do
      nil -> nil
      cc -> cc.category.genre
    end
  end

  defp render_registration_script(assigns) do
    %{
      conn: conn,
      contest: contest,
      changeset: changeset
    } = assigns

    json =
      render_html_safe_json(%{
        changeset: changeset |> remove_obsolete_associations,
        params: conn.params["performance"],
        contest_category_options:
          for {name, id, type, genre} <- cc_options(contest) do
            %{id: id, name: name, type: type, genre: genre}
          end,
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
      })

    ~E{
      <script src="/js/registration.js"></script>
      <script>registrationForm(<%= raw(json) %>)</script>
    }
  end

  defp role_title("soloist"), do: gettext("Soloist")
  defp role_title("ensemblist"), do: gettext("Ensemblist")
  defp role_title("accompanist"), do: gettext("Accompanist")

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
    Enum.map(localized_months(), fn {ordinal, name} ->
      %{value: Integer.to_string(ordinal), label: name}
    end)
  end

  defp role_options do
    Enum.map(JumuParams.participant_roles(), fn
      role -> %{id: role, label: role_name(role)}
    end)
  end

  defp live_role_options do
    Enum.map(JumuParams.participant_roles(), fn
      role -> {role_name(role), role}
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
    Jumubase.Showtime.Instruments.all()
    |> Enum.sort_by(fn {_value, label} -> label end)
    |> Enum.map(fn {value, label} -> %{value: value, label: label} end)
  end

  defp live_instrument_options do
    Jumubase.Showtime.Instruments.all()
    |> Enum.sort_by(fn {_value, label} -> label end)
    |> Enum.map(fn {value, label} -> {label, value} end)
  end

  defp epoch_options do
    Enum.map(JumuParams.epochs(), &%{id: &1, label: epoch_label(&1)})
  end

  defp live_epoch_options do
    Enum.map(JumuParams.epochs(), &{epoch_label(&1), &1})
  end

  defp epoch_label("trad" = epoch), do: JumuParams.epoch_description(epoch)
  defp epoch_label(epoch), do: "#{epoch}) " <> JumuParams.epoch_description(epoch)
end
