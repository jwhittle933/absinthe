defmodule Metallurgy.JPG.Decoder do
  @moduledoc false

  alias __MODULE__

  defstruct [
    :r,
    :bits,
    :bytes,
    :width,
    :height,
    :img1,
    :img3,
    :black_pix,
    :black_stride,
    :ri,
    :n_comp,
    :baseline,
    :progressive,
    :jfif,
    :adobe_transform_valid,
    :adobe_transform,
    :eob_run,
    :comp,
    :prog_coeffs,
    :huff,
    :quant,
    :tmp
  ]

  @type t() :: %__MODULE__{
          r: iodata(),
          bits: %Decoder.Bits{},
          bytes: %Decoder.Bytes{},
          width: integer(),
          height: integer(),
          img1: any(),
          img3: any(),
          black_pix: binary(),
          black_stride: integer(),
          ri: integer(),
          n_comp: integer(),
          baseline: boolean(),
          progressive: boolean(),
          jfif: boolean(),
          adobe_transform_valid: boolean(),
          adobe_transform: integer(),
          eob_run: integer(),
          comp: [struct()],
          prog_coeffs: list(),
          huff: list(),
          quant: list(),
          tmp: [iodata()]
        }

  @doc """
  INCOMPLETE: return decoder with binary list
  """
  def new_decoder(bin) do
    %Decoder{r: :binary.bin_to_list(bin)}
  end

  defmodule Bits do
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

  defmodule Bytes do
    @moduledoc false

    defstruct [:buf, :i, :j, :n_unreadable]

    @type t() :: %__MODULE__{
            buf: [iodata()],
            i: integer(),
            j: integer(),
            n_unreadable: integer()
          }
  end
end
