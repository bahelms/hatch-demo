defmodule Hatch.EmailProvider do
  @moduledoc """
  Email provider API related things
  """

  @behaviour Hatch.Providers.ProviderBehaviour

  def send(msg) do
    # this provider could be supervised and failures retried
    Req.post!(url(), json: msg)
  end

  defp url do
    Application.get_env(:hatch, :email_provider_url, "https://www.mailplus.app/api/email")
  end
end
