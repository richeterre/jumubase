defmodule JumubaseWeb.Internal.ContestCategoryView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [badge: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Foundation.ContestCategory

  @doc """
  Returns a linebreak-separated list of the contest category's flags, if any.
  """
  def notes(%ContestCategory{} = cc) do
    [wespe_nomination_text(cc), accompanist_rating_text(cc)]
    |> Enum.reject(&is_nil/1)
    |> Enum.intersperse(Phoenix.HTML.Tag.tag(:br))
  end

  # Private helpers

  defp wespe_nomination_text(%ContestCategory{} = cc) do
    if cc.allows_wespe_nominations do
      gettext("Allows WESPE nominations")
    end
  end

  defp accompanist_rating_text(%ContestCategory{} = cc) do
    if cc.groups_accompanists do
      gettext("Accompanists rated as group")
    end
  end
end
