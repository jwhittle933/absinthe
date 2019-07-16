defmodule Absinthe.Files do
  alias Absinthe.PNG

  @png_signature <<137::size(8), 80::size(8), 78::size(8), 71::size(8), 13::size(8), 10::size(8),
                   26::size(8), 10::size(8)>>
  @jpg_signature <<255::size(8), 216::size(8)>>

  @doc """
  parse_files module function
  """
  def parse_files(files, opts) do
    with true <- Enum.count(files) > 0 do
      Enum.each(files, fn file ->
        # {:ok, info} = File.stat(file)
        # IO.inspect(info)
        # get_mime(file) |> IO.inspect()
        # open_and_read(file) |> write_to_new_file(file, opts)
        open_and_read(file) |> IO.inspect()
        # show_binary(file)
      end)
    else
      false -> IO.puts("No files")
    end
  end

  def type(<<@png_signature, rest::binary>>), do: :png
  def type(<<@jpg_signature, rest::binary>>), do: :jpg
  def type(_), do: :unknown

  @doc """
  get_files

  Takes opts returned from cli parser
  and returns all files that match the provided
  pattern
  """
  def get_file_list([{:path, path}, {:ext, ext}, {:out, _}]) do
    # [path: path, ext: ext, out: out] = opts
    Path.wildcard("#{path}*#{ext}")
  end

  @doc """
  get_ext

  Returns file extension at a given path
  """
  def get_ext(path) do
    Path.extname(path)
  end

  @doc """
  valid_mime?

  Compares provided file at path with a group
  of chosen mimes. Returns true if pattern matches.
  """
  def valid_mime?(path) do
    ~w(.jpg .jpeg .gif .png .JPG) |> Enum.member?(get_ext(path))
  end

  def show_binary(file) do
    File.read!(file) |> PNG.decode() |> IO.inspect()
  end

  def open_and_read(file) do
    r_file = File.open!(file)
    io_data = r_file |> IO.binread(:line)

    with :ok <- File.close(r_file) do
      io_data
    end
  end

  def write_to_new_file(io_data, file, [{:path, _}, {:ext, ext}, {:out, out}]) do
    with true <- File.dir?(out) do
      new_out = [out, Path.basename(file, ext)] |> Path.join()
      IO.puts(new_out <> ".jpg")
      File.write(new_out <> ".jpg", io_data)
    else
      false ->
        File.mkdir(out)
    end
  end
end
