defmodule Hatch.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hatch.Conversations.{Message, Participant}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    belongs_to :participant_one, Participant, foreign_key: :participant_one_id
    belongs_to :participant_two, Participant, foreign_key: :participant_two_id

    has_many :messages, Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:participant_one_id, :participant_two_id])
    |> validate_required([:participant_one_id, :participant_two_id])
    |> foreign_key_constraint(:participant_one_id)
    |> foreign_key_constraint(:participant_two_id)
    |> unique_constraint([:participant_one_id, :participant_two_id],
      name: :conversations_participants_unique_index
    )
  end
end

