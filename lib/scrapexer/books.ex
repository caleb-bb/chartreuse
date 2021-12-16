defmodule Books do

  alias PageScrape

  def search_libgen(title,element) do
    PageScrape.retrieve_from_url("https://libgen.is/search.php?req=" <> title, element)
  end
end
