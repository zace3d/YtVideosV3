class VideoUpload < ActiveType::Object
  attribute :file, :varchar
  attribute :title, :varchar
  attribute :description, :text

  validates :file, presence: true
  validates :title, presence: true

  def upload!(user)
    account = Yt::Account.new access_token: user.token
    account.upload_video self.file, title: self.title, description: self.description
  end

  require 'streamio-ffmpeg'

  def trancode!()
    movie = FFMPEG::Movie.new(self.file)

    if movie.valid?
      width = movie.width # 640 (width of the movie in pixels)
      height = movie.height # 480 (height of the movie in pixels)

      options = {
        video_codec: "libx264", resolution: "480x480", x264_vprofile: "high", x264_preset: "slow",
        threads: 2, custom: %w(-vf crop=iw:iw:0:0 -map 0:0 -map 0:1)
      }

      transcoded_movie = movie.transcode("tmp/movie.mp4", options) { |progress| puts progress } # 0.2 ... 0.5 ... 1.0

      #raise "#{transcoded_movie.width} ----- #{transcoded_movie.height}".to_yaml
      transcoded_movie
    else
      movie
    end
  end
end