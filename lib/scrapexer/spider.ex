defmodule Spider do
  import MapSet

  def domain_crawler(url,must_crawl,have_crawled) do

    uncrawled_links = PageScrape.parent_domain_links(url)
    |> new()
    |> difference(have_crawled)


    case size(uncrawled_links) do
      0 -> have_crawled
      _ -> domain_crawler(next,uncrawled_links,put(have_crawled,url))
    end
  end

    def domain_crawler(url) do
      domain_crawler(url,new([url]),new([]))
    end
end
