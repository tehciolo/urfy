defmodule Urfy.Repo do
  use Ecto.Repo,
    otp_app: :urfy,
    adapter: Ecto.Adapters.SQLite3
end
