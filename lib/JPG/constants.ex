defmodule Metallurgy.JPG.Constants do
  @moduledoc false

  Module.register_attribute(__MODULE__, :dc_table, accumulate: false)
  Module.register_attribute(__MODULE__, :ac_table, accumulate: false)
  Module.register_attribute(__MODULE__, :max_tc, accumulate: false)
  Module.register_attribute(__MODULE__, :max_th, accumulate: false)
  Module.register_attribute(__MODULE__, :max_tq, accumulate: false)
  Module.register_attribute(__MODULE__, :max_components, accumulate: false)
  Module.register_attribute(__MODULE__, :adobe_transform_unknown, accumulate: false)
  Module.register_attribute(__MODULE__, :adobe_transform_ycbcr, accumulate: false)
  Module.register_attribute(__MODULE__, :adobe_transform_ycbcrk, accumulate: false)
  Module.register_attribute(__MODULE__, :sof0, accumulate: false)
  Module.register_attribute(__MODULE__, :sof1, accumulate: false)
  Module.register_attribute(__MODULE__, :sof2, accumulate: false)
  Module.register_attribute(__MODULE__, :rst0, accumulate: false)
  Module.register_attribute(__MODULE__, :rst7, accumulate: false)
  Module.register_attribute(__MODULE__, :soi, accumulate: false)
  Module.register_attribute(__MODULE__, :sos, accumulate: false)
  Module.register_attribute(__MODULE__, :dqt, accumulate: false)
  Module.register_attribute(__MODULE__, :dri, accumulate: false)
  Module.register_attribute(__MODULE__, :com, accumulate: false)
  Module.register_attribute(__MODULE__, :app0, accumulate: false)
  Module.register_attribute(__MODULE__, :app14, accumulate: false)
  Module.register_attribute(__MODULE__, :app15, accumulate: false)
  Module.register_attribute(__MODULE__, :eoi, accumulate: false)
  Module.register_attribute(__MODULE__, :pad, accumulate: false)
  Module.register_attribute(__MODULE__, :unzig, accumulate: false)

  @dc_table 0
  @ac_table 1
  @max_tc 1
  @max_th 3
  @max_tq 3
  @max_components 4

  @adobe_tranform_unknown 0
  @adobe_tranform_ycbcr 1
  @adobe_tranform_ycbcrk 2

  @doc """
  Module constants representing portions of JPEG image.
  """
  # Start of Frame (Baseline Sequential)
  @sof0 <<0xC0>>
  # Start of Frame (Extended Sequential)
  @sof1 <<0xC1>>
  # Start of Frame (Progressive)
  @sof2 <<0xC2>>
  # ReSTart (0)
  @rst0 <<0xD0>>
  # ReSTart (7)
  @rst7 <<0xD7>>
  # Start of Image
  @soi <<0xD8>>
  # Start of Scan
  @sos <<0xDA>>
  # Define Quantization Table
  @dqt <<0xDB>>
  # Define Restart Interval
  @dri <<0xDD>>
  # Comment
  @com <<0xFE>>
  # JFIF tag
  @app0 <<0xE0>>
  # Adobe tag
  @app14 <<0xEE>>
  # Graphic Converter
  @app15 <<0xEF>>
  # End of Image
  @eoi <<0xD9>>
  # Padding
  @pad <<0x00>>

  @doc """
  unzig maps from the zig-zag ordering to the natural ordering.
  """
  @unzig [
    0,
    1,
    8,
    16,
    9,
    2,
    3,
    10,
    17,
    24,
    32,
    25,
    18,
    11,
    4,
    5,
    12,
    19,
    26,
    33,
    40,
    48,
    41,
    34,
    27,
    20,
    13,
    6,
    7,
    14,
    21,
    28,
    35,
    42,
    49,
    56,
    57,
    50,
    43,
    36,
    29,
    22,
    15,
    23,
    30,
    37,
    44,
    51,
    58,
    59,
    52,
    45,
    38,
    31,
    39,
    46,
    53,
    60,
    61,
    54,
    47,
    55,
    62,
    63
  ]
end
