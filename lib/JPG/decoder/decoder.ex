defmodule Metallurgy.JPG.Decoder do
  @moduledoc false

  alias __MODULE__

  defstruct [
    :r,
    :bits,
    # bytes is a bytes buffer
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

  @type t() :: %Decoder{
          r: iodata(),
          bits: %Decoder.Bits{},
          bytes: %Decoder.Bytes{},
          width: integer(),
          height: integer(),
          img1: any(),
          img3: %Decoder.YCBCR{},
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
          comp: [%Decoder.Component{}],
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

  defmodule Component do
    @moduledoc """
    Component specification
    """
    alias __MODULE__

    @enforce_keys [:h, :v, :c, :tq]
    defstruct [:h, :v, :c, :tq]

    @type t() :: %Component{
            h: integer(),
            v: integer(),
            c: integer(),
            tq: integer()
          }
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
            # buf[i:j] are the buffered bytes read from the underlying
            # reader that haven't yet been passed further on.
            buf: [iodata()],
            i: integer(),
            j: integer(),
            # n_unreadable is the number of backup bytes to back
            # up i after overshooting. It can be 0, 1, 2
            n_unreadable: integer()
          }
  end

  defmodule YCBCR do
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
      @moduledoc false
      alias __MODULE__
      defstruct [:min, :max]

      @type t() :: %Rectangle{
              min: %Rectangle.Point{},
              max: %Rectangle.Point{}
            }

      defmodule Point do
        @moduledoc false
        alias __MODULE__
        defstruct [:x, :y]

        @type t() :: %Point{
                x: integer(),
                y: integer()
              }
      end
    end
  end

  defmodule Gray do
    @moduledoc """
    Gray module for Gray struct
    """
    alias __MODULE__
    defstruct [:pix, :stride, :rect]

    @type t() :: %Gray{
            pix: [integer()],
            stride: integer(),
            rect: %Gray.Rectangle{}
          }

    defmodule Rectangle do
      @moduledoc false
      alias __MODULE__
      defstruct [:min, :max]

      @type t() :: %Rectangle{
              min: %Rectangle.Point{},
              max: %Rectangle.Point{}
            }

      defmodule Point do
        @moduledoc false
        alias __MODULE__
        defstruct [:x, :y]

        @type t() :: %Point{
                x: integer(),
                y: integer()
              }
      end
    end
  end
end
