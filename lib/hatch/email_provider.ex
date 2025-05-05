defmodule Hatch.EmailProvider do
  def send(msg) do
    Req.post!(url(), json: msg)
  end

  defp url do
    Application.get_env(:hatch, :email_provider_url, "https://www.mailplus.app/api/email")
  end
end
