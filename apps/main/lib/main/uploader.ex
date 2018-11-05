defmodule Uploader do
  @moduledoc false

  alias ExAws.S3

  require Logger

  @bucket Application.get_env(:ex_aws, :bucket)

  def upload_image(path) when path in ["", nil], do: ""

  def upload_image(image_path) do
    {:ok, image_binary} = File.read(image_path)

    filename =
      image_binary
      |> image_extension()
      |> unique_filename()

    with {:ok, _response} <- S3.put_object(@bucket, filename, image_binary) |> ExAws.request() do
      {:ok, "https://s3.amazonaws.com/#{@bucket}/#{filename}"}
    else
      {:error, message} ->
        Logger.error inspect message
        {:ok, ""}
    end
  end

  defp unique_filename(extension) do
    UUID.uuid4(:hex) <> extension
  end

  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xff, 0xD8, _::binary>>), do: ".jpg"
end
