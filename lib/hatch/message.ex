defmodule Hatch.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :from, :string
    field :to, :string
    field :type, :string
    field :body, :string
    field :attachments, {:array, :string}
    field :messaging_provider_id, :string
    field :timestamp, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:from, :to, :type, :body, :attachments, :timestamp])
    |> validate_required([:from, :to, :body, :timestamp])
  end
end
