defmodule Absinthe.CLI do
  def parse(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [path: :string, ext: :string],
        aliases: [P: :path, E: :ext]
      )

    opts
  end
end
