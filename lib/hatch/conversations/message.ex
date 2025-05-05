defmodule Hatch.Conversations.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hatch.Conversations.Conversation

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :from, :string
    field :to, :string
    field :type, :string
    field :body, :string
    field :attachments, {:array, :string}
    field :timestamp, :utc_datetime

    belongs_to :conversation, Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:from, :to, :type, :body, :attachments, :timestamp, :conversation_id])
    |> validate_required([:from, :to, :body, :timestamp])
    |> foreign_key_constraint(:conversation_id)
  end
end
