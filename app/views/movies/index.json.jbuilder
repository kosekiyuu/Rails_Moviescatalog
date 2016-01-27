json.array!(@movies) do |movie|
  json.extract! movie, :id, :file_name, :local_file_path, :file_basename, :movie_title, :contributor, :contributor_comment, :rating, :play_counts, :size, :path, :duration, :creation_time, :bitrate, :video_codec, :colorspace, :video_bitrate, :resolution, :audio_codec, :audio_channels, :audio_bitrate, :audio_sample_rate
  json.url movie_url(movie, format: :json)
end
