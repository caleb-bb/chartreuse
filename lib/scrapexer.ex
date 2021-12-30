defmodule Scrapexer do
  @moduledoc """
  Scrapexer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def create_directory_name(url) do
    url
    |> PageScrape.base_url
    |> String.split("www.")
    |> tl
    |> hd
    |> String.split(".")
    |> hd
  end

  def create_html_file_name(url) do
    filename = url
    |> String.split(".org")
    |> tl
    |> hd
    |> String.replace(~r/\//,"_") #replace slashes with underscores to avoid directory problems

    case filename do
      "" -> "main.html"
      _ -> filename
    end
  end

  def writefile(url) do
    directory = create_directory_name(url)
    filename = create_html_file_name(url)
    path = directory <> "/" <> filename
    text = PageScrape.html_as_string(url)

    File.mkdir(directory)
    {:ok, file} = File.open(path, [:write,:read,:utf8])

    IO.puts(file, text)
  end

  def write_all(url) do
    Spider.domain_crawler(url)
    |> Enum.map(fn x -> writefile(x) end)
  end

end
