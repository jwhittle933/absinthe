defmodule Absinthe.Guards do
  defguard is_jpg(value) when binary_part(value, 0, 2) == <<0xFF, 0xD8>>

  defguard is_jfif(value)
           when binary_part(value, 0, 4) ==
                  <<0xFF, 0xD8, 0xFF, 0xE0>>

  defguard is_png(value)
           when binary_part(value, 0, 8) == <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
end
