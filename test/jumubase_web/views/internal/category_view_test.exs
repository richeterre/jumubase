defmodule JumubaseWeb.Internal.CategoryViewTest do
  use JumubaseWeb.ConnCase, async: true
  alias Jumubase.JumuParams
  alias JumubaseWeb.Internal.CategoryView

  describe "genre_tag/1" do
    test "returns a tag for each genre" do
      for genre <- JumuParams.genres() do
        category = build(:category, genre: genre)
        assert CategoryView.genre_tag(category) != nil
      end
    end
  end

  describe "type_tag/1" do
    test "returns a tag for each category type" do
      for type <- JumuParams.category_types() do
        category = build(:category, type: type)
        assert CategoryView.type_tag(category) != nil
      end
    end
  end
end
