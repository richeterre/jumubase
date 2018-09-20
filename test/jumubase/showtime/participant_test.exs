defmodule Jumubase.ParticipantTest do
  use Jumubase.DataCase
  alias Jumubase.Showtime.Participant

  describe "changeset" do
    test "is valid with valid attributes" do
      params = params_for(:participant)
      changeset = Participant.changeset(%Participant{}, params)
      assert changeset.valid?
    end

    test "is invalid without a given name" do
      params = params_for(:participant, given_name: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "is invalid without a family name" do
      params = params_for(:participant, family_name: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "is invalid without a birthdate" do
      params = params_for(:participant, birthdate: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "is invalid without a phone number" do
      params = params_for(:participant, phone: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "is invalid without an email" do
      params = params_for(:participant, email: nil)
      changeset = Participant.changeset(%Participant{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid email" do
      for invalid_email <- ["", "a", "a@", "@", "@b", "a@b", "a@b.", "a@.c"] do
        params = params_for(:participant, email: invalid_email)
        changeset = Participant.changeset(%Participant{}, params)
        refute changeset.valid?
      end
    end

    test "is valid with a valid email" do
      for valid_email <- ["a@b.c", "a+b@c.d"] do
        params = params_for(:participant, email: valid_email)
        changeset = Participant.changeset(%Participant{}, params)
        assert changeset.valid?
      end
    end
  end
end
