defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import Ecto.Changeset
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.{AgeGroups, Contest}
  alias Jumubase.Showtime.Participant

  @doc """
  Returns text that guides the user to a Kimu registration form with the given path.
  """
  def kimu_link(conn_or_socket, %Contest{} = c) do
    path = Routes.performance_path(conn_or_socket, :new, c)

    gettext("for Kimu, there’s a %{form_link}",
      form_link: safe_to_string(link(gettext("separate form"), to: path))
    )
    |> raw
  end

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

  def has_epoch_field?(performance_cs, contest) do
    needs_epochs?(performance_cs, contest)
  end

  # Private helpers

  defp get_name(%Participant{given_name: nil, family_name: nil}), do: nil
  defp get_name(%Participant{given_name: given_name, family_name: nil}), do: given_name
  defp get_name(%Participant{given_name: nil, family_name: family_name}), do: family_name
  defp get_name(%Participant{} = pt), do: full_name(pt)

  defp get_genre(performance_cs, contest) do
    cc_id = get_field(performance_cs, :contest_category_id)

    case Enum.find(contest.contest_categories, &(&1.id == cc_id)) do
      nil -> nil
      cc -> cc.category.genre
    end
  end

  defp needs_epochs?(performance_cs, contest) do
    cc_id = get_field(performance_cs, :contest_category_id)

    case Enum.find(contest.contest_categories, &(&1.id == cc_id)) do
      nil -> true
      cc -> cc.category.uses_epochs
    end
  end

  defp role_title("soloist"), do: gettext("Soloist")
  defp role_title("ensemblist"), do: gettext("Ensemblist")
  defp role_title("accompanist"), do: gettext("Accompanist")

  defp birthdate_year_options(season) do
    AgeGroups.birthyear_range(season)
  end

  defp role_options do
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
    |> Enum.map(fn {value, label} -> {label, value} end)
  end

  defp epoch_options do
    Enum.map(JumuParams.epochs(), &{epoch_label(&1), &1})
  end

  defp epoch_label("trad" = epoch), do: JumuParams.epoch_description(epoch)
  defp epoch_label(epoch), do: "#{epoch}) " <> JumuParams.epoch_description(epoch)
end
