defmodule Metallurgy.Builtin do
  @doc """
  Reference: https://stackoverflow.com/questions/32642907/how-does-the-copy-function-work

  copy copies elements from a source list into a destination list.
  The source and destination may overlap. Copy returns the new list and the
  number of elements copied, which will be the minimum of length(src) and length(dst).
  """
  @spec copy(list(integer()), list(integer())) ::
          {list(integer() | none()), integer()} | {:atom, integer()}
  def copy([], _src), do: {:error, 0}
  def copy(dst, []), do: {dst, 0}

  def copy(dst, src) do
    # subtract 1 from each value for index use
    dst_l = Enum.count(dst) - 1
    src_l = Enum.count(src) - 1

    case dst_l >= src_l do
      true ->
        case dst_l > src_l do
          true ->
            {smaller_src_to_dst({src, src_l}, {dst, dst_l}), src_l + 1}

          false ->
            {src, src_l}
        end

      false ->
        {larger_src_to_dst({src, src_l}, {dst, dst_l}), dst_l + 1}
    end
  end

  defp smaller_src_to_dst({src, src_l}, {dst, dst_l}) do
    dst_tail = dst |> Enum.slice(Range.new(src_l, dst_l))
    src ++ dst_tail
  end

  defp larger_src_to_dst({src, src_l}, {dst, dst_l}) do
    src |> Enum.slice(Range.new(0, dst_l))
  end
end
