defmodule RetryOn.Organization do
  use Ecto.Schema

  schema "organizations" do
    field :name, :string
  end
end
