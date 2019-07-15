defmodule Absinte.JPG.Decoder do
  @moduledoc false

  use Absinthe.JPG.Context, :bits
  use Absinthe.JPG.Context, :bytes

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
    :r_comp,
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
          bits: struct(),
          bytes: struct(),
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
          adobe_transform_valie: boolean(),
          adobe_tranform: integer(),
          eob_run: integer(),
          comp: [struct()],
          prog_coeffs: list(),
          huff: list(),
          quant: list(),
          tmp: [iodata()]
        }
end
