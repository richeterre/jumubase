defmodule JumubaseWeb.Internal.PageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.PageView, only: [document_link: 2]
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.Email

  def admin_email do
    config = Application.get_env(:jumubase, Email)
    config[:admin_email]
  end
end
