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

  def write_path(path_list,domain) do
    [head | tail] = path_list
    File.mkdir_p(head)

    case tail do
      [] ->  File.cd("/home/caleb/elixir/scrapexer/#{domain}")
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
    html = PageScrape.html_as_string(url)
    domain = derive_base_name(url)

    url
    |> derive_path_list
    |> write_path(html,domain)
  end

  def write_full_directory(url_list) do
    write_root_directory(hd(url_list))
    File.cd(derive_base_name(hd(url_list)))
    Enum.map(url_list, &write_path_from_url(&1))
  end



end
