defmodule ChainSpec do
  @moduledoc """
  Single entrypoint for fetching chain-specific constants.
  """

  def get_config,
    do: Application.fetch_env!(:lambda_ethereum_consensus, __MODULE__) |> Keyword.fetch!(:config)

  def get_preset, do: get_config().get("PRESET_BASE") |> String.to_atom()

  def get_fork_version_for_epoch(epoch) do
    cond do
      epoch >= get("DENEB_FORK_EPOCH") -> get("DENEB_FORK_VERSION")
      epoch >= get("CAPELLA_FORK_EPOCH") -> get("CAPELLA_FORK_VERSION")
      true -> raise "Forks before Capella are not supported"
    end
  end

  # NOTE: this only works correctly for Capella
  def get(name), do: get_config().get(name)

  def get_genesis_validators_root do
    Application.fetch_env!(:lambda_ethereum_consensus, __MODULE__)
    |> Keyword.fetch!(:genesis_validators_root)
  end
end
