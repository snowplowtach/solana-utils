defmodule SolanaUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :solana_utils,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.18.0"},
      {:solana, "~> 0.2.0"},
      {:ed25519, "~> 1.4.0"},
      {:borsh_ex, "~> 0.1.0"},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
