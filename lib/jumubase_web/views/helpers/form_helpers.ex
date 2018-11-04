defmodule JumubaseWeb.FormHelpers do
  import Phoenix.HTML
  import Phoenix.HTML.Form

  def inline_date_select(form, field, opts \\ []) do
    builder = fn b ->
      ~e"""
      <div class="form-inline">
        <%= b.(:day, class: "form-control") %>
        <%= b.(:month, class: "form-control") %>
        <%= b.(:year, class: "form-control") %>
      </div>
      """
    end

    date_select(form, field, [builder: builder] ++ opts)
  end
end
