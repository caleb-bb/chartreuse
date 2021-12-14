defmodule Scrapexer.Repo do
  use Ecto.Repo,
    otp_app: :scrapexer,
    adapter: Ecto.Adapters.Postgres
end
