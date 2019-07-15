defmodule Absinthe.JPG.YCBCR do
  @moduledoc """
  Chroma subsample ratio used in YCbCr image

  YCbCr is an in-memory image of Y'CbCr colors. There is one Y sample per pixel, but each Cb and Cr sample
  can span one or more pixels. YStride and len(Y) are typically multiples of 8

  For 4:4:4, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/1
  For 4:2:2, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/2
  For 4:2:0, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/4
  For 4:4:0, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/2
  For 4:1:1, CStride == YStride/4 && len(Cb) == len(Cr) == len(Y)/4
  For 4:1:0, CStride == YStride/4 && len(Cb) == len(Cr) == len(Y)/4
  """
  alias __MODULE__

  @ycbcr_subsample_ratio444 0
  @ycbcr_subsample_ratio422 1
  @ycbcr_subsample_ratio420 2
  @ycbcr_subsample_ratio440 3
  @ycbcr_subsample_ratio411 4
  @ycbcr_subsample_ratio410 5

  defstruct [:y, :Cb, :Cr, :ystride, :cstride, :subsample_ratio, :rect]

  @type t() :: %YCBCR{
          y: integer(),
          Cb: integer(),
          Cr: integer(),
          subsample_ratio: integer(),
          rect: %YCBCR.Rectangle{}
        }

  defmodule Rectangle do
    alias __MODULE__
    defstruct [:min, :max]

    @type t() :: %Rectangle{
            min: %Rectangle.Point{},
            max: %Rectangle.Point{}
    }


    defmodule Point do
      defstruct [:x, :y]

      @type t() :: %__MODULE__{
        x: integer(),
        y: integer()
      }
    end
  end
end
