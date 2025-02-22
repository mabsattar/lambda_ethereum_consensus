defmodule BitListTest do
  use ExUnit.Case
  alias LambdaEthereumConsensus.SszEx
  alias LambdaEthereumConsensus.Utils.BitList

  describe "Sub-byte BitList" do
    test "build from binary" do
      input_encoded = <<237, 7>>
      {:ok, decoded} = SszEx.decode(input_encoded, {:bitlist, 10})
      assert BitList.set?({decoded, 10}, 0) == true
      assert BitList.set?({decoded, 10}, 1) == false
      assert BitList.set?({decoded, 10}, 4) == false
      assert BitList.set?({decoded, 10}, 9) == true

      {updated_bitlist, _} =
        {decoded, 10}
        |> BitList.set(1)
        |> BitList.set(4)
        |> BitList.clear(0)
        |> BitList.clear(9)

      {:ok, <<254, 5>>} = SszEx.encode(updated_bitlist, {:bitlist, 10})
    end

    test "sets a single bit" do
      bl = BitList.new(<<0b10100000, 0b1011100, 0b1>>)

      for pos <- 0..15 do
        assert bl
               |> BitList.set(pos)
               |> BitList.set?(pos)
      end
    end

    test "clears a single bit" do
      bl = BitList.new(<<0b10100000, 0b1011100, 0b1>>)

      for pos <- 0..15 do
        assert bl
               |> BitList.clear(pos)
               |> BitList.set?(pos)
               |> Kernel.not()
      end
    end

    test "queries if a bit is set correctly using little-endian bit indexing" do
      expected_values = [
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        true,
        false
      ]

      bl = BitList.new(<<0b10100000, 0b1011100, 0b1>>)
      assert Enum.map(0..15, &BitList.set?(bl, &1)) == expected_values
    end
  end
end
