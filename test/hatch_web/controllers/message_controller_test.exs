defmodule HatchWeb.MessageControllerTest do
  use HatchWeb.ConnCase
  alias Hatch.Repo
  alias Hatch.Conversations.{Participant, Conversation}

  @valid_attrs %{
    "from" => "+1234567890",
    "to" => "+0987654321",
    "type" => "sms",
    "body" => "Hello, world!",
    "attachments" => [],
    "timestamp" => "2024-11-01T14:00:00Z"
  }

  describe "create message" do
    test "creates participants if they don't exist", %{conn: conn} do
      post(conn, ~p"/api/messages", message: @valid_attrs)
      assert Repo.get_by(Participant, phone_number: @valid_attrs["from"])
      assert Repo.get_by(Participant, phone_number: @valid_attrs["to"])
    end

    test "creates conversation if it doesn't exist", %{conn: conn} do
      post(conn, ~p"/api/messages", message: @valid_attrs)
      assert convo = Repo.one(Conversation) |> Repo.preload(:participant_one)
      assert convo.participant_one.phone_number == @valid_attrs["from"]
    end

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

    test "message is added to existing conversation" do
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

  describe "sms message" do
    test "message is sent to the appropriate provider" do
    end
  end

  describe "mms message" do
    test "message is sent to the appropriate provider" do
    end
  end

  describe "email message" do
    test "message is sent to the appropriate provider" do
    end
  end
end

