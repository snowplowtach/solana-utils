defmodule SolanaUtils.CandyMachine do
  require Logger
  import SolanaUtils.Config
  import SolanaUtils.CandyMachine.Config

  alias SolanaUtils.Api

  def list_tokens(id) do
    case candy_machine_pda(id) do
      {:ok, program, _} ->
        opts = %{
          encoding: "base64",
          dataSlice: %{offset: 33, length: 32},
          filters: [
            %{
              memcmp: %{
                offset: 326,
                bytes: B58.encode58(program)
              }
            }
          ]
        }

        case Api.get_program_accounts(metadata_program_id(), opts) do
          {:ok, %{body: body}} ->
            result = get_in(body, ["result"])

            Enum.map(result, fn account ->
              account
              |> get_in(["account", "data"])
              |> hd()
              |> Base.decode64!()
              |> B58.encode58()
            end)

          error ->
            Logger.error("[CandyMachine] error #{inspect(error)}")
            {:error, :unknown}
        end

      _ ->
        {:error, :not_found}
    end
  end

  defp candy_machine_pda(id) do
    Solana.Key.find_address(
      ["candy_machine", B58.decode58!(id)],
      B58.decode58!(program_v2_id())
    )
  end
end
