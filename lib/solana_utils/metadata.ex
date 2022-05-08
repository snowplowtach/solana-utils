defmodule SolanaUtils.Metadata.Collection do
  use BorshEx.Schema
  defstruct verified: nil, key: nil

  borsh_schema do
    field(:verified, "boolean")
    field(:key, {"array", {"u8", 32}})
  end
end

defmodule SolanaUtils.Metadata.Creator do
  use BorshEx.Schema
  defstruct address: nil, verified: nil, share: nil

  borsh_schema do
    field(:address, {"array", {"u8", 32}})
    field(:verified, "boolean")
    field(:share, "u8")
  end
end

defmodule SolanaUtils.Metadata.Data do
  use BorshEx.Schema
  defstruct name: nil, symbol: nil, uri: nil, seller_fee_basis_points: nil, creators: nil

  borsh_schema do
    field(:name, "string")
    field(:symbol, "string")
    field(:uri, "string")
    field(:seller_fee_basis_points, "u16")
    field(:creators, {"option", {"array", SolanaUtils.Metadata.Creator}})
  end
end

defmodule SolanaUtils.Metadata do
  use BorshEx.Schema

  defstruct key: nil,
            update_authority: nil,
            mint: nil,
            data: nil,
            primary_sale_happened: nil,
            is_mutable: nil,
            edition_nonce: nil,
            collection: nil

  @keys [
    "Uninitialized",
    "EditionV1",
    "MasterEditionV1",
    "ReservationListV1",
    "MetadataV1",
    "ReservationListV2",
    "MasterEditionV2",
    "EditionMarker",
    "UseAuthorityRecord",
    "CollectionAuthorityRecord"
  ]

  @token_standards [
    "NonFungible",
    "FungibleAsset",
    "Fungible",
    "NonFungibleEdition"
  ]

  borsh_schema do
    field(:key, {"enum", @keys})
    field(:update_authority, {"array", {"u8", 32}})
    field(:mint, {"array", {"u8", 32}})
    field(:data, SolanaUtils.Metadata.Data)
    field(:primary_sale_happened, "boolean")
    field(:is_mutable, "boolean")
    field(:edition_nonce, {"option", "u8"})
    field(:token_standard, {"option", {"enum", @token_standards}})
    field(:collection, {"option", SolanaUtils.Metadata.Collection})
  end
end
