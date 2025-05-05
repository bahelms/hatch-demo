defmodule Hatch.HTTPClient do
  def post(%{type: nil}, msg) do
    EmailProvider.send(msg)
  end

  def post(%{type: type}, msg) when type in ["sms", "mms"] do
    PhoneProvider.send(msg)
  end
end
