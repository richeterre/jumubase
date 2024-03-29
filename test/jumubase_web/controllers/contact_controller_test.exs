defmodule JumubaseWeb.ContactControllerTest do
  use JumubaseWeb.ConnCase
  import Swoosh.TestAssertions

  describe "send_message/2" do
    @valid_params %{
      "name" => "A",
      "email" => "a@b.c",
      "email_repeat" => "",
      "message" => "Lorem ipsum"
    }

    test "lets the user send a contact message", %{conn: conn} do
      conn = post(conn, Routes.contact_path(conn, :send_message), %{"contact" => @valid_params})

      assert get_flash(conn, :success) =~ "Your message has been sent!"
      assert redirected_to(conn) == Routes.page_path(conn, :contact)

      assert_email_sent(
        JumubaseWeb.Email.contact_message(%{name: "A", email: "a@b.c", message: "Lorem ipsum"})
      )
    end

    test "shows an error if the hidden field is filled (indicating a spambot)", %{conn: conn} do
      params = %{@valid_params | "email_repeat" => "a@b.c"}
      conn = post(conn, Routes.contact_path(conn, :send_message), %{"contact" => params})

      assert get_flash(conn, :error) =~ "Please fill in only fields that are visible in the form."
      assert redirected_to(conn) == Routes.page_path(conn, :contact)
      assert_no_email_sent()
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

      conn = post(conn, Routes.contact_path(conn, :send_message), %{"contact" => params})

      assert get_flash(conn, :error) =~ "Please fill in all fields and try again!"
      assert redirected_to(conn) == Routes.page_path(conn, :contact)
      assert_no_email_sent()
    end
  end
end
