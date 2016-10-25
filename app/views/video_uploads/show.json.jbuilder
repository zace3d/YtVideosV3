if @video.present?
	json.(@video, :id, :link, :title, :published_at, :likes, :dislikes, :uid, :created_at, :updated_at)
end