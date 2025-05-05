defmodule Hatch.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "participants" do
    field :phone_number, :string
    field :email, :string

    has_many :conversations_as_one, Hatch.Conversation, foreign_key: :participate_one_id
    has_many :conversations_as_two, Hatch.Conversation, foreign_key: :participate_two_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:phone_number, :email])
    |> unique_constraint(:phone_number)
    |> unique_constraint(:email)
  end
end

