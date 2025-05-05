defmodule Hatch.PhoneProvider do
  def send(msg) do
    Req.post!(url(), json: msg)
  end

  defp url do
    Application.get_env(:hatch, :phone_provider_url, "https://www.provider.app/api/messages")
  end
end
