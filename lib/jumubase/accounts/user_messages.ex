defmodule Jumubase.Accounts.UserMessages do
  use Phauxth.UserMessages.Base
  import Jumubase.Gettext

  def default_error do
    dgettext("auth", "Unfortunately, the email or password was incorrect.")
  end
end
