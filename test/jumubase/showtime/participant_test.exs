defmodule Jumubase.ParticipantTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
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

    test "removes whitespace around the given name" do
      params = params_for(:participant, given_name: " Vera Lynn  ")
      changeset = Participant.changeset(%Participant{}, params)
      assert Changeset.get_change(changeset, :given_name) == "Vera Lynn"
    end

    test "removes whitespace around the family name" do
      params = params_for(:participant, family_name: "  van Beethoven ")
      changeset = Participant.changeset(%Participant{}, params)
      assert Changeset.get_change(changeset, :family_name) == "van Beethoven"
    end

    test "removes whitespace around the phone number" do
      params = params_for(:participant, phone: " 0049 30 1234567  ")
      changeset = Participant.changeset(%Participant{}, params)
      assert Changeset.get_change(changeset, :phone) == "0049 30 1234567"
    end

    test "removes whitespace around the email address" do
      params = params_for(:participant, email: "  a@b.c  ")
      changeset = Participant.changeset(%Participant{}, params)
      assert Changeset.get_change(changeset, :email) == "a@b.c"
    end
  end
end
