defmodule HatchWeb.MessageController do
  use HatchWeb, :controller

  alias Hatch.{Conversations, Conversations.Message}

  action_fallback HatchWeb.FallbackController

  @doc """
  Creates a message.
  """
  def create(conn, %{"message" => message_params}) do
    with {:ok, %Message{} = message} <- Conversations.add_message(message_params) do
      conn
      |> put_status(:created)
      |> render(:show, message: message)
    end
  end
end
