defmodule SolanaUtils do
  require Logger
  import SolanaUtils.Config

  def list_user_tokens(address_public_key) do
    filters = %{
      programId: spl_token_program_id()
    }

    options = %{
      encoding: "jsonParsed",
      commitment: "processed"
    }

    case SolanaUtils.Api.get_token_accounts_by_owner(address_public_key, filters, options) do
      {:ok, %{body: response}} ->
        tokens = get_in(response, ["result", "value"]) || []

        tokens =
          tokens
          |> Enum.filter(
            &(get_in(&1, ["account", "data", "parsed", "info", "tokenAmount", "uiAmount"]) >= 1)
          )
          |> Enum.map(&get_in(&1, ["account", "data", "parsed", "info", "mint"]))
          |> Enum.reject(&is_nil/1)

        {:ok, tokens}

      error ->
        Logger.error("[Solana] error #{inspect(error)}")
        {:error, []}
    end
  end

  def get_metadata_full(token) do
    case get_metadata(token) do
      %SolanaUtils.Metadata{} = metadata -> {metadata, fetch_uri_metadata(metadata)}
      other -> other
    end
  end

  defp fetch_uri_metadata(%SolanaUtils.Metadata{data: %SolanaUtils.Metadata.Data{uri: uri}})
       when not is_nil(uri) do
    :hackney.request(
      :get,
      uri,
      [
        {"Content-Type", "application/json"}
      ],
      "",
      [
        :with_body,
        :follow_redirect
      ] ++ [SolanaUtils.Hackney.options()]
    )
    |> case do
      {:ok, 200, _, body} -> Jason.decode!(body)
      _ -> nil
    end
  end

  def get_metadata(token) do
    account =
      case get_metadata_account_pda(token) do
        {:ok, account, _nonce} -> B58.encode58(account)
        _ -> nil
      end

    if account do
      {:ok, response} = SolanaUtils.Api.get_account_info(account)
      decode_data(response.body)
    end
  end

  defp decode_data(%{"result" => %{"value" => %{"data" => [data | _]}}}) do
    data_decoded = Base.decode64!(data)

    metadata =
      case SolanaUtils.Metadata.deserialize(data_decoded) do
        {:ok, result} -> result
        {:error, result, _} -> result
      end

    humanize(metadata)
  end

  defp decode_data(_), do: nil

  defp get_metadata_account_pda(token) do
    Solana.Key.find_address(
      ["metadata", B58.decode58!(metadata_program_id()), B58.decode58!(token)],
      B58.decode58!(metadata_program_id())
    )
  end

  defp humanize(%SolanaUtils.Metadata{} = metadata) do
    mint = metadata.mint |> :binary.list_to_bin() |> B58.encode58()
    update_authority = metadata.update_authority |> :binary.list_to_bin() |> B58.encode58()
    data = humanize(metadata.data)
    collection = humanize(metadata.collection)

    %{
      metadata
      | mint: mint,
        update_authority: update_authority,
        data: data,
        collection: collection
    }
  end

  defp humanize(%SolanaUtils.Metadata.Collection{} = collection) do
    key = collection.key |> :binary.list_to_bin() |> B58.encode58()
    %{collection | key: key}
  end

  defp humanize(%SolanaUtils.Metadata.Data{} = data) do
    name = data.name |> :binary.bin_to_list() |> Enum.reject(&(&1 == 0)) |> :binary.list_to_bin()
    uri = data.uri |> :binary.bin_to_list() |> Enum.reject(&(&1 == 0)) |> :binary.list_to_bin()

    symbol =
      data.symbol |> :binary.bin_to_list() |> Enum.reject(&(&1 == 0)) |> :binary.list_to_bin()

    creators = Enum.map(data.creators, &humanize/1)
    %{data | name: name, uri: uri, symbol: symbol, creators: creators}
  end

  defp humanize(%SolanaUtils.Metadata.Creator{} = creator) do
    address = creator.address |> :binary.list_to_bin() |> B58.encode58()
    %{creator | address: address}
  end

  defp humanize(nil), do: nil

  def get_tokens_by_symbol(tokens) do
    tokens =
      Enum.map(tokens, &get_in(&1, ["account", "data", "parsed", "info", "mint"]))
      |> Enum.reject(&is_nil/1)

    Enum.map(tokens, fn token ->
      try do
        if metadata = get_metadata(token) do
          %{token: token, name: metadata.data.name, symbol: metadata.data.symbol}
        else
          %{token: token, name: nil, symbol: nil}
        end
      rescue
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end
