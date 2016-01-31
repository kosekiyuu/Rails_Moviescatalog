class Movie < ActiveRecord::Base
    acts_as_taggable
    acts_as_taggable_on :tags
    ActsAsTaggableOn.remove_unused_tags = true

    acts_as_commentable
    belongs_to :user
    has_many :vote
    has_many :movies_tags


    scope :fulltext_search, ->(search_word) { where("match(movie_title, contributor, contributor_comment) against('#{search_word}')") }
    scope :newer_upload_sort, -> { order('created_at desc') }
    scope :older_upload_sort, -> { order('created_at asc') }
    scope :play_counts_sort, -> { order('play_counts desc') }
    scope :rating_like_dislike_sort, -> { order('rating desc') }
    scope :longer_duration_sort, -> { order('duration desc') }
    scope :shorter_duration_sort, -> { order('duration asc') }

    FFMPEG.ffmpeg_binary = "/usr/local/bin/ffmpeg"
    # "/usr/bin/ffmpeg"

    # FFMPEG.ffprobe_binary = "/usr/local/bin/ffprobe"

    validates :movie_title, presence: true, length: { in: 10..100 }



    def movies_search(search_query, search_column, search_result_sort, page_number)
        if search_column == 'tags'
            search_matched_tags = ActsAsTaggableOn::Tag.where("match(name) against('#{search_query}')").map{|x| x.name}
            searched_movies = Movie.tagged_with(search_matched_tags, :any => true).uniq
        else
            searched_movies = Movie.fulltext_search("#{search_query}")
        end

        if search_result_sort.to_i == 1
            movies = searched_movies.newer_upload_sort.page(page_number)
        elsif search_result_sort.to_i == 2
            movies = searched_movies.older_upload_sort.page(page_number)
        elsif search_result_sort.to_i == 3
            movies = searched_movies.play_counts_sort.page(page_number)
        elsif search_result_sort.to_i == 4
            movies = searched_movies.longer_duration_sort.page(page_number)
        elsif search_result_sort.to_i == 5
            movies = searched_movies.shorter_duration_sort.page(page_number)
        elsif search_result_sort.to_i == 6
            movies = searched_movies.rating_like_dislike_sort.page(page_number)
        else
            movies = searched_movies.page(page_number)
        end

        return movies
    end


    def tag_update(movie, params_tag_list, params_tag_check_box_list)
        send_tag = ("#{params_tag_list}".gsub(/(\s|　)+/, ',').split(',') | [params_tag_check_box_list].flatten.compact).reject{ |c| c.blank? }

        unless (send_tag == movie.tag_list)
            movie.tag_list = send_tag
            return movie.save
            MoviesTags.new.tag_recommend_database
        end
    end


    def timespan(duration)
        if duration < 3600
            Time.now.midnight.advance(:seconds => duration).strftime('%M:%S')
        else
            Time.now.midnight.advance(:seconds => duration).strftime('%T')
        end
    end


    MOVIES_SAVE_PATH = "/public/videos/"

    def upload_movie_extract_info_and_save(upload_movie, current_user)
        unless File.directory?(File.join(Rails.root, MOVIES_SAVE_PATH))
            FileUtils.mkdir_p(File.join(Rails.root, MOVIES_SAVE_PATH))
        end


        if upload_movie.present? && upload_movie.tempfile.size > 0 && upload_movie.class==ActionDispatch::Http::UploadedFile
                temp_movie = FFMPEG::Movie.new(upload_movie.tempfile.path)

                if temp_movie.valid?
                        new_mp4_filename = "movie_#{Time.now.strftime("%Y%m%d_%H%M%S")}_#{SecureRandom.hex(32)}.mp4"
                        new_mp4_filepath = File.join(Rails.root, MOVIES_SAVE_PATH, new_mp4_filename)

                        if temp_movie.video_codec.include?("h264")
                            # mp4(h264)形式である場合はそのままTempファイルの動画をコピー
                            FileUtils.cp(upload_movie.tempfile.path, new_mp4_filepath)
                            FileUtils.chmod(0644, new_mp4_filepath)
                        else
                            # mp4(h264)形式でない場合はmp4(h264)形式へ変換
                            options = {
                                video_codec: "libx264",
                                audio_codec: "libfdk_aac",
                                movflags: "faststart",
                            }
                            temp_movie.transcode(new_mp4_filepath, options)
                        end

                        movie = FFMPEG::Movie.new(new_mp4_filepath)
                        movie_info_hash = {
                            :file_name=>new_mp4_filename,
                            :local_file_path=>File.join(MOVIES_SAVE_PATH, new_mp4_filename),
                            :file_basename=>upload_movie.original_filename,
                            :contributor => current_user.contributor,
                            :play_counts => 0,
                        }
                        [:size, :path, :duration, :creation_time, :bitrate, :video_codec, :colorspace, :video_bitrate, :resolution, :audio_codec, :audio_channels, :audio_bitrate, :audio_sample_rate,].each do |i|
                                    movie_info_hash[i] = movie.send(i)
                        end
                    return movie_info_hash
                else
                    return nil
                end
        end
    end


  THUMBNAILS_SAVE_PATH = File.join(Rails.root, "/public/images/thumbnails/")
  THUMBNAILS_COUNT = 5

    def movie_thumbnails_create(movie_file_path)
        unless File.directory?(THUMBNAILS_SAVE_PATH)
            FileUtils.mkdir_p(THUMBNAILS_SAVE_PATH)
        end

        movie_basename = File.basename(movie_file_path, File.extname(movie_file_path)) #拡張子を除いた動画ファイル名本体

        movie = FFMPEG::Movie.new(movie_file_path)
        movie_thumbnail_divided_time = (movie.duration / (THUMBNAILS_COUNT+1))    #動画サムネイル画像の間隔秒数を算出

        Thread.start do
            THUMBNAILS_COUNT.times do |i|
                thumbnail_jpeg_path = File.join(THUMBNAILS_SAVE_PATH, "#{movie_basename}_#{i}.jpg")
                unless File.exist?(thumbnail_jpeg_path)
                movie_thumbnail_time = movie_thumbnail_divided_time*(i+1) #動画サムネイル画像を作る秒数
                movie.screenshot(
                    thumbnail_jpeg_path,
                    :seek_time => movie_thumbnail_time,
                    :resolution => '105x80'
                  )
                end
            end
        end.join
    end


    def movie_and_thumbnails_destroy(movie_file_path)
        FileUtils.rm(movie_file_path) if File.exist?(movie_file_path)

        movie_basename = File.basename(movie_file_path, File.extname(movie_file_path)) #拡張子を除いた動画ファイル名本体
        THUMBNAILS_COUNT.times do |i|
            thumbnail_file_path = File.join(THUMBNAILS_SAVE_PATH, "#{movie_basename}_#{i}.jpg")
            FileUtils.rm(thumbnail_file_path) if File.exist?(thumbnail_file_path)
        end
    end


end
