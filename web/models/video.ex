defmodule Rumbl.Video do
  use Rumbl.Web, :model

  schema "videos" do
    field :"\\", :string
    field :url, :string
    field :title, :string
    field :description, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category
    field :slug, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ :empty) do
    struct
    |> cast(params, [ :url, :title, :description, :category])
    |> validate_required([ :url, :title, :description, :category])
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")

  end

end
