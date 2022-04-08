defmodule SolanaUtils.Config do
  def spl_token_program_id() do
    config(:spl_token_program_id)
  end

  def api_url() do
    config(:api_url)
  end

  def metadata_program_id do
    config(:metadata_program_id)
  end

  def config(key) do
    config()
    |> Keyword.get(key)
  end

  def config, do: Application.get_env(:solana_utils, :solana)
end

defmodule SolanaUtils.CandyMachine.Config do
  def program_v2_id do
    config(:program_v2_id)
  end

  def config(key) do
    config()
    |> Keyword.get(key)
  end

  def config, do: Application.get_env(:solana_utils, :candy_machine)
end
