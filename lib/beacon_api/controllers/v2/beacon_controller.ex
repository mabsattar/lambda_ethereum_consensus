defmodule BeaconApi.V2.BeaconController do
  alias BeaconApi.ApiSpec
  alias BeaconApi.ErrorController
  alias LambdaEthereumConsensus.Store.BlockDb
  alias LambdaEthereumConsensus.Store.Blocks
  use BeaconApi, :controller

  plug(OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true)

  def open_api_operation(action) when is_atom(action) do
    # NOTE: action can take a bounded amount of values
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def get_block_operation,
    do: ApiSpec.spec().paths["/eth/v2/beacon/blocks/{block_id}"].get

  @spec get_block(Plug.Conn.t(), any) :: Plug.Conn.t()
  def get_block(conn, %{block_id: "head"}) do
    # TODO: determine head and return it
    conn |> block_not_found()
  end

  def get_block(conn, %{block_id: "finalized"}) do
    # TODO
    conn |> block_not_found()
  end

  def get_block(conn, %{block_id: "justified"}) do
    # TODO
    conn |> block_not_found()
  end

  def get_block(conn, %{block_id: "genesis"}) do
    # TODO
    conn |> block_not_found()
  end

  def get_block(conn, %{block_id: "0x" <> hex_block_id}) do
    with {:ok, block_root} <- Base.decode16(hex_block_id, case: :mixed),
         %{} = block <- Blocks.get_signed_block(block_root) do
      conn |> block_response(block)
    else
      nil -> conn |> block_not_found()
      _ -> conn |> ErrorController.bad_request("Invalid block ID: 0x#{hex_block_id}")
    end
  end

  def get_block(conn, %{block_id: block_id}) do
    with {slot, ""} when slot >= 0 <- Integer.parse(block_id),
         {:ok, block} <- BlockDb.get_block_by_slot(slot) do
      conn |> block_response(block)
    else
      :not_found ->
        conn |> block_not_found()

      _ ->
        conn |> ErrorController.bad_request("Invalid block ID: #{block_id}")
    end
  end

  defp block_response(conn, block) do
    conn
    |> json(%{
      version: "capella",
      execution_optimistic: true,
      finalized: false,
      data: %{
        # TODO: return block as JSON
        message: inspect(block)
      }
    })
  end

  defp block_not_found(conn) do
    conn
    |> put_status(404)
    |> json(%{
      code: 404,
      message: "Block not found"
    })
  end
end
