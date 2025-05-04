defmodule Hatch.Messages do
  import Ecto.Query, warn: false
  alias Hatch.Repo
  alias Hatch.Message

  @doc """
  Creates a message.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end
end

