defmodule Absinthe.CLI do
  def parse(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [path: :string, ext: :string, out: :string],
        aliases: [P: :path, E: :ext, O: :out]
      )
    opts
  end
end
