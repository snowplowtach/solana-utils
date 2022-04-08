defmodule SolanaTest do
  use ExUnit.Case
  doctest Solana

  test "greets the world" do
    assert SolanaUtils.hello() == :world
  end
end
