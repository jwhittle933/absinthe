defmodule Absinthe.JPG.Bits do
  @moduledoc """
  Bits holds the unprocessee bitst that have been taken from the byte-stream.
  The n least significant bits of a form the unread bits, to be read in MSB to
  LSB order
  """

  @enforce_keys [:a, :m, :n]
  defstruct [:a, :m, :n]

  @type t() :: %__MODULE__{
          a: integer(),
          m: integer(),
          n: integer()
        }
end
