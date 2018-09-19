defmodule Jumubase.ParticipantTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Participant

  describe "changeset" do
    test "with valid attributes" do
      params = params_for(:participant)
      changeset = Participant.changeset(%Participant{}, params)
      assert changeset.valid?
    end

    test "without a given name" do
      params = params_for(:participant, given_name: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "without a family name" do
      params = params_for(:participant, family_name: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "without a birthdate" do
      params = params_for(:participant, birthdate: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "without a phone number" do
      params = params_for(:participant, phone: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "without an email" do
      params = params_for(:participant, email: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end
  end
end
