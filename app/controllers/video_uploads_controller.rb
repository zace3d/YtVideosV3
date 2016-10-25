class VideoUploadsController < ApplicationController
  def new
    @video_upload = VideoUpload.new
  end

  def create
    respond_to do |format|
      if request.format.json?
        @video_upload = VideoUpload.new(title: params[:title],
                                      description: params[:description],
                                      file: params[:file].try(:tempfile).try(:to_path))
      else
        @video_upload = VideoUpload.new(title: params[:video_upload][:title],
                                      description: params[:video_upload][:description],
                                      file: params[:video_upload][:file].try(:tempfile).try(:to_path))
      end

      if @video_upload.save
        transcoded_video = @video_upload.trancode!

        @video_upload.file = transcoded_video.path if transcoded_video.present?

        uploaded_video = @video_upload.upload!(current_user)

        if uploaded_video.failed?
          flash[:error] = 'There was an error while uploading your video...'

          format.html { redirect_to root_url }
          format.json { render json: '{"error": "There was an error while uploading your video..."}', status: :unprocessable_entity }
        else
          @video = Video.create({link: "https://www.youtube.com/watch?v=#{uploaded_video.id}"})
          flash[:success] = 'Your video has been uploaded!'

          format.html { redirect_to root_url }
          format.json { render :show, status: :created }
          #format.json { render json: '{"ok": "Your video has been uploaded!"}', status: :created }
        end
      else
        format.html { render :new }
        format.json { render json: '{"error": "There was an error while uploading your video..."}', status: :unprocessable_entity }
      end
    end
  end
end