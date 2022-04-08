defmodule SolanaUtils.Api.Client do
  import SolanaUtils.Config

  def request(body) do
    :hackney.request(:post, api_url(), headers(), Jason.encode!(body), [
      :with_body | SolanaUtils.Hackney.options()
    ])
  end

  defp headers do
    [
      {"Content-Type", "application/json"}
    ]
  end
end
