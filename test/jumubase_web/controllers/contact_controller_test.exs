defmodule JumubaseWeb.ContactControllerTest do
  use JumubaseWeb.ConnCase
  use Bamboo.Test

  describe "send_message/2" do
    @valid_params %{
      "name" => "A",
      "email" => "a@b.c",
      "message" => "Lorem ipsum"
    }

    test "lets the user send a contact message", %{conn: conn} do
      conn = post(conn, contact_path(conn, :send_message), %{"contact" => @valid_params})

      assert get_flash(conn, :success) =~ "Your message has been sent!"
      assert redirected_to(conn) == page_path(conn, :contact)
      assert_delivered_email JumubaseWeb.Email.contact_message(
        %{name: "A", email: "a@b.c", message: "Lorem ipsum"}
      )
    end

    test "shows an error if the name is left empty", %{conn: conn} do
      test_invalid_input(conn, %{"name" => ""})
    end

    test "shows an error if the email is left empty", %{conn: conn} do
      test_invalid_input(conn, %{"email" => ""})
    end

    test "shows an error if the email has invalid format", %{conn: conn} do
      for invalid_email <- ["a", "a@b", "@b.c"] do
        test_invalid_input(conn, %{"email" => invalid_email})
      end
    end

    test "shows an error if the message is left empty", %{conn: conn} do
      test_invalid_input(conn, %{"message" => ""})
    end

    # Private helpers

    defp test_invalid_input(conn, invalid_params) do
      params = @valid_params |> Map.merge(invalid_params)

      conn = post(conn, contact_path(conn, :send_message), %{"contact" => params})

      assert get_flash(conn, :error) =~ "Please fill in all fields and try again!"
      assert redirected_to(conn) == page_path(conn, :contact)
      assert_no_emails_delivered()
    end
  end
end
