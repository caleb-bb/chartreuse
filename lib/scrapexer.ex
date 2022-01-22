defmodule Scrapexer do
  @moduledoc """
  Scrapexer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def derive_base_name(url) do
    url
    |> PageScrape.base_url
    |> String.split(".")
    |> tl
    |> hd
  end

  def derive_path_list(url) do
    String.trim(url,"https://")
    |> String.split("/")
    |> tl
  end

  def write_path([head | tail],domain) do
    File.mkdir_p(head)
    case tail do
      [] ->

        File.cd("/home/caleb/elixir/scrapexer/#{domain}")
      _ ->  File.cd(head)
            write_path(tail,domain)
    end
  end

  def write_image(image_tuple) do
    File.write(elem(image_tuple,0),elem(image_tuple,1))
  end

  def batch_write_image(url,pattern) do
    url
    |> PageScrape.images_from_url(pattern)
    |> Enum.map(&write_image(&1))
  end

  def write_root_directory(url) do
    url
    |> PageScrape.base_url
    |> derive_base_name
    |> File.mkdir_p
  end

  def write_path_from_url(url) do
    domain = derive_base_name(url)
    path_list = url
    |> derive_path_list

    case path_list do
      [] -> write_path([domain],domain)
      _ -> write_path(path_list,domain)
    end
  end

  def write_full_directory(url_list) do
    write_root_directory(hd(url_list))
    File.cd(derive_base_name(hd(url_list)))

    Enum.map(url_list, &write_path_from_url(&1))
  end

  def write_html(url) do
    html = url
    |> PageScrape.html_as_string

    path = url
    |> derive_path_list

    IO.inspect(html)
    IO.inspect(path)

    File.write(path,html)
  end

end
