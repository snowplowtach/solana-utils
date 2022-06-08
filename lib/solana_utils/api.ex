defmodule SolanaUtils.Api do
  alias SolanaUtils.Api.Client

  @base_body %{
    jsonrpc: "2.0"
  }
  def get_program_accounts(public_key, options \\ %{}) do
    body =
      Map.merge(@base_body, %{
        method: "getProgramAccounts",
        params: [
          public_key,
          options
        ],
        id: UUID.uuid4()
      })

    Client.request(body)
    |> handle_response()
  end

  def get_token_accounts_by_owner(public_key, filters \\ %{}, options \\ %{}) do
    body =
      Map.merge(@base_body, %{
        method: "getTokenAccountsByOwner",
        params: [
          public_key,
          filters,
          options
        ],
        id: UUID.uuid4()
      })

    Client.request(body)
    |> handle_response()
  end

  def get_multiple_accounts_info(public_keys, options \\ %{encoding: "jsonParsed"}) do
    body =
      Map.merge(@base_body, %{
        method: "getMultipleAccounts",
        params: [
          public_keys,
          options
        ],
        id: UUID.uuid4()
      })

    Client.request(body)
    |> handle_response()
  end

  def get_account_info(public_key, options \\ %{encoding: "jsonParsed"}) do
    body =
      Map.merge(@base_body, %{
        method: "getAccountInfo",
        params: [
          public_key,
          options
        ],
        id: UUID.uuid4()
      })

    Client.request(body)
    |> handle_response()
  end

  defp handle_response({:ok, 200, _, body}) do
    response = %{body: Jason.decode!(body), status: 200}
    {:ok, response}
  end

  defp handle_response({_, status, _, body}) do
    response = %{body: Jason.decode!(body), status: status}
    {:error, response}
  end
end
