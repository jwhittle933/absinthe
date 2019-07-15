defmodule Absinthe.Guards do
  defguard is_JPG(value) when binary_part(value, 0, 2) == <<255, 216>>

  defguard is_JFIF(value)
           when binary_part(value, 0, 4) ==
                  <<255, 216, 255, 224>>

  defguard is_PNG(value)
           when binary_part(value, 0, 8) == <<137, 80, 78, 71, 13, 10, 26, 10>>
end
