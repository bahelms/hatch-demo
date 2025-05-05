defmodule Hatch.Conversations do
  import Ecto.Query, warn: false
  alias Hatch.Repo
  alias Hatch.Conversations.{Participant, Message, Conversation}

  def add_message(msg_attrs) do
    msg_attrs = standardize_attrs(msg_attrs)
    msg = Message.changeset(%Message{}, msg_attrs)

    if msg.valid? do
      msg_attrs
      |> load_participants()
      |> load_conversation()
      |> then(&Map.put(msg_attrs, "conversation_id", &1.id))
      |> create_message()
      |> send_message()
    else
      {:error, msg}
    end
  end

  defp standardize_attrs(attrs) do
    Map.update(attrs, "type", nil, &String.downcase/1)
  end

  defp load_participants(%{"from" => from, "to" => to, "type" => type}) do
    [load_participant(from, type), load_participant(to, type)]
  end

  defp load_participant(value, nil) do
    Participant
    |> Repo.get_by(email: value)
    |> maybe_create_participant(:email, value)
  end

  defp load_participant(value, type) when type in ["sms", "mms"] do
    Participant
    |> Repo.get_by(phone_number: value)
    |> maybe_create_participant(:phone_number, value)
  end

  defp maybe_create_participant(nil, field, value) do
    %Participant{}
    |> Participant.changeset(%{field => value})
    |> Repo.insert!()
  end

  defp maybe_create_participant(participant, _field, _value), do: participant

  defp load_conversation([%{id: id_one}, %{id: id_two}]) do
    from(c in Conversation,
      where:
        (c.participant_one_id == ^id_one or
           c.participant_two_id == ^id_one) and
          (c.participant_one_id == ^id_two or
             c.participant_two_id == ^id_two)
    )
    |> Repo.one()
    |> maybe_create_conversation(id_one, id_two)
  end

  defp maybe_create_conversation(nil, id_one, id_two) do
    %Conversation{}
    |> Conversation.changeset(%{participant_one_id: id_one, participant_two_id: id_two})
    |> Repo.insert!()
  end

  defp maybe_create_conversation(conversation, _one, _two), do: conversation

  defp create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def send_message({:ok, msg}) do
    # This should probably be async
    provider(msg.type).send(msg)
    {:ok, msg}
  end

  defp provider(nil) do
    Application.get_env(:hatch, :email_provider, Hatch.EmailProvider)
  end

  defp provider(type) when type in ["sms", "mms"] do
    Application.get_env(:hatch, :phone_provider, Hatch.PhoneProvider)
  end
end
