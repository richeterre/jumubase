defmodule JumubaseWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML
  alias Ecto.Changeset

  @doc """
  Generates tag for inlined form input errors.
  The feedback_field value can be used to override which form element is targeted by the
  LiveView feedback logic (e.g. for a :date_select field that has multiple form elements).
  """
  def error_tag(form, field, feedback_field \\ nil) do
    form.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn error ->
      content_tag(:small, translate_error(error),
        class: "help-block",
        phx_feedback_for: input_id(form, feedback_field || field)
      )
    end)
  end

  def error_list_tag(errors) do
    content_tag :ul do
      for error <- errors do
        content_tag(:li, translate_error(error))
      end
    end
  end

  @doc """
  Traverses the changeset's errors and translates them.
  """
  def get_translated_errors(%Changeset{} = cs) do
    Changeset.traverse_errors(cs, &translate_error/1)
  end

  # Private helpers

  # Translates an error message using gettext.
  defp translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(Jumubase.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Jumubase.Gettext, "errors", msg, opts)
    end
  end
end
