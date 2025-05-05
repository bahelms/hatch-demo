defmodule HatchWeb.MessageJSON do
  alias Hatch.Conversations.Message

  def show(%{message: message}) do
    %{data: data(message)}
  end

  defp data(%Message{} = message) do
    %{
      id: message.id,
      from: message.from,
      to: message.to,
      type: message.type,
      body: message.body,
      attachments: message.attachments,
      timestamp: message.timestamp
    }
  end
end
