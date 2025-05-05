defmodule Hatch.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    belongs_to :participant_one, Hatch.Participant, foreign_key: :participate_one_id
    belongs_to :participant_two, Hatch.Participant, foreign_key: :participate_two_id

    has_many :messages, Hatch.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:participate_one_id, :participate_two_id])
    |> validate_required([:participate_one_id, :participate_two_id])
    |> foreign_key_constraint(:participate_one_id)
    |> foreign_key_constraint(:participate_two_id)
    |> unique_constraint([:participate_one_id, :participate_two_id], name: :conversations_participants_unique_index)
  end
end 