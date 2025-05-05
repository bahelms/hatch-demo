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

  defp load_participants(%{"from" => from_email, "to" => to_email, "type" => "email"}) do
    from(p in Participant, where: p.email == ^from_email or p.email == ^to_email)
    |> Repo.all()
    |> maybe_create_participants(from_email, to_email, :email)
  end

  defp load_participants(%{"from" => from_number, "to" => to_number, "type" => type})
       when type in ["sms", "mms"] do
    from(p in Participant, where: p.phone_number == ^from_number or p.phone_number == ^to_number)
    |> Repo.all()
    |> maybe_create_participants(from_number, to_number, :phone_number)
  end

  defp maybe_create_participants([], from_number, to_number, field) do
    [
      Participant.changeset(%Participant{}, %{field => from_number}),
      Participant.changeset(%Participant{}, %{field => to_number})
    ]
    |> Enum.map(&Repo.insert!(&1, returning: true))
  end

  defp maybe_create_participants(participants, _from, _to, _field), do: participants

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

  defp send_message(msg) do
    msg
  end
end
