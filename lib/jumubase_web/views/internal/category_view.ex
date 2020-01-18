defmodule JumubaseWeb.Internal.CategoryView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.Category

  @doc """
  Returns a textual tag describing the category's genre.
  """
  def genre_tag(%Category{genre: genre}) do
    content_tag(:span, genre_name(genre), class: "label label-default")
  end

  @doc """
  Returns a textual tag describing the category type.
  """
  def type_tag(%Category{type: type}) do
    content_tag(:span, type_name(type), class: "label label-default")
  end

  @doc """
  Returns a textual tag describing the category group.
  """
  def group_tag(%Category{group: group}) do
    content_tag(:span, group_name(group), class: "label label-default")
  end

  def bw_code_tag(%Category{bw_code: nil}), do: nil

  def bw_code_tag(%Category{bw_code: bw_code}) do
    content_tag(:code, bw_code)
  end

  @doc """
  Returns a list of possible `genre` values suitable for forms.
  """
  def form_genres do
    Enum.map(JumuParams.genres(), &{genre_name(&1), &1})
  end

  @doc """
  Returns a list of possible `type` values suitable for forms.
  """
  def form_types do
    Enum.map(JumuParams.category_types(), &{type_name(&1), &1})
  end

  @doc """
  Returns a list of possible `group` values suitable for forms.
  """
  def form_groups do
    Enum.map(JumuParams.category_groups(), &{group_name(&1), &1})
  end

  @doc """
  Maps internal genres to user-facing genre names.
  """
  def genre_name(genre) do
    case genre do
      "classical" -> gettext("Classical")
      "popular" -> gettext("Popular")
      "kimu" -> gettext("Kimu")
    end
  end

  # Private helpers

  # Maps internal category types to user-facing category type names.
  defp type_name(type) do
    case type do
      "solo" -> gettext("Solo")
      "ensemble" -> gettext("Ensemble")
      "solo_or_ensemble" -> gettext("Solo/Ensemble")
    end
  end

  # Maps internal category groups to user-facing category group names.
  defp group_name(group) do
    case group do
      "piano" -> gettext("Piano")
      "strings" -> gettext("String Instruments")
      "wind" -> gettext("Wind Instruments")
      "plucked" -> gettext("Plucked Instruments")
      "classical_vocals" -> gettext("Classical Vocals")
      "accordion" -> gettext("Accordion")
      "harp" -> gettext("Harp")
      "organ" -> gettext("Organ")
      "percussion" -> gettext("Percussion")
      "special_lineups" -> gettext("Special Lineups")
      "pop_vocals" -> gettext("Pop Vocals")
      "pop_instrumental" -> gettext("Pop Instrumental")
      "kimu" -> gettext("Kimu")
    end
  end
end
