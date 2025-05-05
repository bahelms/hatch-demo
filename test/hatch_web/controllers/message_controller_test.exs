defmodule HatchWeb.MessageControllerTest do
  use HatchWeb.ConnCase
  import Mox
  alias Hatch.Repo
  alias Hatch.Conversations.{Participant, Conversation}

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    :ok
  end

  @valid_attrs %{
    "from" => "+1234567890",
    "to" => "+0987654321",
    "type" => "sms",
    "body" => "Hello, world!",
    "attachments" => [],
    "timestamp" => "2024-11-01T14:00:00Z"
  }

  describe "create message" do
    test "creates participants by phone number if they don't exist", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
      post(conn, ~p"/api/messages", message: @valid_attrs)
      assert Repo.get_by(Participant, phone_number: @valid_attrs["from"])
      assert Repo.get_by(Participant, phone_number: @valid_attrs["to"])
    end

    test "creates one participant if the other exists", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
      create_participant(%{phone_number: @valid_attrs["from"]})
      post(conn, ~p"/api/messages", message: @valid_attrs)
      assert Repo.get_by(Participant, phone_number: @valid_attrs["to"])
    end

    test "creates participants by email if they don't exist", %{conn: conn} do
      expect(Hatch.EmailProviderMock, :send, fn msg -> {:ok, msg} end)

      email_attrs =
        @valid_attrs
        |> Map.merge(%{"from" => "a@b.com", "to" => "c@d.com"})
        |> Map.delete("type")

      post(conn, ~p"/api/messages", message: email_attrs)
      assert Repo.get_by(Participant, email: email_attrs["from"])
      assert Repo.get_by(Participant, email: email_attrs["to"])
    end

    test "creates conversation if it doesn't exist", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
      post(conn, ~p"/api/messages", message: @valid_attrs)
      assert convo = Repo.one(Conversation) |> Repo.preload(:participant_one)
      assert convo.participant_one.phone_number == @valid_attrs["from"]
    end

    test "creates message with valid data", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
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

    test "message is added to existing conversation", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
      one = create_participant(%{phone_number: @valid_attrs["from"]})
      two = create_participant(%{phone_number: @valid_attrs["to"]})
      convo = create_conversation(one, two)

      %{"data" => %{"conversation_id" => convo_id}} =
        conn
        |> post(~p"/api/messages", message: @valid_attrs)
        |> json_response(201)

      assert convo_id == convo.id
    end

    test "conversations can be cross channel", %{conn: conn} do
      expect(Hatch.PhoneProviderMock, :send, fn msg -> {:ok, msg} end)
      expect(Hatch.EmailProviderMock, :send, fn msg -> {:ok, msg} end)
      create_participant(%{phone_number: "+1234567890", email: "hey@there.com"})
      create_participant(%{phone_number: "+0987654321", email: "ahoy@matey.com"})

      conn
      |> post(~p"/api/messages", message: @valid_attrs)
      |> post(~p"/api/messages",
        message:
          @valid_attrs
          |> Map.merge(%{
            "from" => "ahoy@matey.com",
            "to" => "hey@there.com"
          })
          |> Map.delete("type")
      )

      assert Repo.aggregate(Conversation, :count, :id) == 1
      assert [convo | []] = Conversation |> Repo.all() |> Repo.preload(:messages)
      assert length(convo.messages) == 2
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
    test "message is sent to the appropriate provider", %{conn: conn} do
      Hatch.PhoneProviderMock
      |> expect(:send, fn msg ->
        assert msg.type == "sms"
        {:ok, msg}
      end)

      post(conn, ~p"/api/messages", message: @valid_attrs)
    end
  end

  describe "mms message" do
    test "message is sent to the appropriate provider", %{conn: conn} do
      Hatch.PhoneProviderMock
      |> expect(:send, fn msg ->
        assert msg.type == "mms"
        {:ok, msg}
      end)

      post(conn, ~p"/api/messages", message: %{@valid_attrs | "type" => "mms"})
    end
  end

  describe "email message" do
    test "message is sent to the appropriate provider", %{conn: conn} do
      Hatch.EmailProviderMock
      |> expect(:send, fn msg ->
        assert is_nil(msg.type)
        {:ok, msg}
      end)

      post(conn, ~p"/api/messages",
        message:
          @valid_attrs
          |> Map.merge(%{"from" => "a@b.com", "to" => "c@d.com"})
          |> Map.delete("type")
      )
    end
  end

  defp create_participant(attrs) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert!()
  end

  defp create_conversation(%{id: one}, %{id: two}) do
    %Conversation{}
    |> Conversation.changeset(%{participant_one_id: one, participant_two_id: two})
    |> Repo.insert!()
  end
end
