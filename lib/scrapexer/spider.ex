defmodule Spider do
  import MapSet

  def domain_crawler(url,must_crawl,have_crawled) do

    uncrawled_links = PageScrape.parent_domain_links(url)
    |> new()
    |> union(must_crawl)
    |> difference(have_crawled)
    |> delete(url)

    case size(uncrawled_links) do
      0 -> to_list(have_crawled)
      _ -> domain_crawler(hd(to_list(uncrawled_links)),uncrawled_links,put(have_crawled,url))
    end
  end

    def domain_crawler(url) do
      domain_crawler(url,new([url]),new([]))
    end
end

