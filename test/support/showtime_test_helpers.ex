defmodule Jumubase.ShowtimeTestHelpers do
  import Jumubase.Factory

  @doc """
  Returns valid attributes for creating an appearance,
  including nested data that isn't handled by the Factory.
  """
  def valid_appearance_attrs do
    params_with_assocs(:appearance)
    # Replace linked by nested participant
    |> Map.delete(:participant_id)
    |> Map.put(:participant, params_for(:participant))
  end
end
