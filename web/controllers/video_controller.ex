defmodule Rumbl.VideoController do
 use Rumbl.Web, :controller
  # alias Rumbl.User
  alias Rumbl.Video
  alias Rumbl.Category
  # alias Rumbl.Repo

  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    apply(__MODULE__,action_name(conn),
          [ conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    videos = Repo.all(user_videos(user))
    videos = Repo.preload(videos, :category)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset = user
    |> build_assoc(:videos)
    |> Video.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    changeset = user
    |> build_assoc(:videos)
    |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)
    video = Repo.preload(video, :category)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  def user_videos(user) do
    assoc(user, :videos)
  end



  defp load_categories(conn, _) do
    query = Category |> Category.alphabetical |> Category.names_and_ids
    categories = Repo.all query
    assign(conn, :categories, categories)

  end


  # def usvica1 do
  #   user = Repo.one from u in User, where: u.id == 1
  #   videos = Repo.all(Rumbl.VideoController.user_videos(user))
  #   videos = Repo.preload(videos, :category)
  #   [hvid|_] = videos
  #   hvid.category.name
  # end


  # plug :load_category_name when action in [:index]
  # defp load_category_name(conn, _) do
  #   query = Category |> Category.name
  #   categ_name = Repo.all query
  #   assign(conn, :categ_name, categ_name)
  # end




end
