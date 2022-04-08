import Config

config :solana_utils, :solana,
  api_url: System.get_env("SOLANA_API_URL", "https://api.devnet.solana.com"),
  spl_token_program_id: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
  metadata_program_id: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"

config :solana_utils, :candy_machine, program_v2_id: "cndy3Z4yapfJBmL3ShUp5exZKqR3z33thTzeNMm2gRZ"
