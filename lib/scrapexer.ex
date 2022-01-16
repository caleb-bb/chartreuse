defmodule Scrapexer do
  @moduledoc """
  Scrapexer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def base_name(url) do
    url
    |> PageScrape.base_url
    |> String.split(".")
    |> tl
    |> hd
  end

  def treat_url(url) do
    String.trim(url,"https://")
    |> String.split("/")
    |> tl
  end

  def path_from_treated(treated_url,contents,domain) do
    [head | tail] = treated_url
    IO.inspect(treated_url)
    File.mkdir_p(head)

    case tail do
      [] -> File.write("#{head}/" <> head,contents)
            IO.puts(domain)
            File.cd("/home/caleb/elixir/scrapexer/#{domain}")
      _ ->  File.cd(head)
            path_from_treated(tail,contents,domain)
    end
  end

  def write_single_image(image_tuple) do
    IO.inspect(image_tuple)
    File.write(elem(image_tuple,0),elem(image_tuple,1))
  end

  def save_images(url,pattern) do
    url
    |> PageScrape.images_from_url(pattern)
    |> Enum.map(&write_single_image(&1))
  end

  def directory_from_url(url) do
    url
    |> PageScrape.base_url
    |> base_name
    |> File.mkdir_p
  end

  def path_from_url(url) do
    html = PageScrape.html_as_string(url)
    domain = base_name(url)

    url
    |> treat_url
    |> path_from_treated(html,domain)
  end

  def generate_directory(url_list) do
    directory_from_url(hd(url_list))
    File.cd(base_name(hd(url_list)))

    Enum.map(url_list, &path_from_url(&1))
  end



end
