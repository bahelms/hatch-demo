defmodule HatchWeb.MessageControllerTest do
  use HatchWeb.ConnCase

  @valid_attrs %{
    "from" => "+1234567890",
    "to" => "+0987654321",
    "type" => "sms",
    "body" => "Hello, world!",
    "attachments" => [],
    "timestamp" => "2024-11-01T14:00:00Z"
  }

  describe "create message" do
    test "creates message with valid data", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: @valid_attrs)

      assert %{
               "data" => %{
                 "id" => _id,
                 "from" => "+1234567890",
                 "to" => "+0987654321",
                 "type" => "sms",
                 "body" => "Hello, world!",
                 "attachments" => [],
                 "timestamp" => "2024-11-01T14:00:00Z"
               }
             } = json_response(conn, 201)
    end

    test "returns error with empty message body", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: %{@valid_attrs | "body" => ""})

      assert %{
               "errors" => %{
                 "body" => ["can't be blank"]
               }
             } = json_response(conn, 422)
    end

    test "returns error with invalid timestamp", %{conn: conn} do
      conn =
        post(conn, ~p"/api/messages", message: %{@valid_attrs | "timestamp" => "invalid-date"})

      assert %{
               "errors" => %{
                 "timestamp" => ["is invalid"]
               }
             } = json_response(conn, 422)
    end

    test "returns error with missing required fields", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: %{})

      assert %{
               "errors" => %{
                 "from" => ["can't be blank"],
                 "to" => ["can't be blank"],
                 "body" => ["can't be blank"],
                 "timestamp" => ["can't be blank"]
               }
             } = json_response(conn, 422)
    end
  end
end

