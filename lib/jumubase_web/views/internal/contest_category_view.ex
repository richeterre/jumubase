defmodule JumubaseWeb.Internal.ContestCategoryView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.AppearanceView, only: [badge: 1]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Foundation.ContestCategory

  @doc """
  Returns an info text explaining how accompanists are rated in the contest category.
  """
  def accompanist_rating_info(%ContestCategory{} = cc) do
    case cc.groups_accompanists do
      true -> gettext("as group")
      false -> gettext("separately")
    end
  end
end
