defmodule JumubaseWeb.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.LayoutView, only: [title: 0]
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
end
