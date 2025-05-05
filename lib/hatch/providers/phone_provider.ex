defmodule Hatch.PhoneProvider do
  @moduledoc """
  Phone provider API related things
  """

  @behaviour Hatch.Providers.ProviderBehaviour

  def send(msg) do
    # this provider could be supervised and failures retried
    Req.post!(url(), json: msg)
  end

  defp url do
    Application.get_env(:hatch, :phone_provider_url, "https://www.provider.app/api/messages")
  end
end
