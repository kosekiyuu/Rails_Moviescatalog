class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

    def tag_edit
        @movie = Movie.find(params[:id])

        if params[:checked_tags].present?
            Movie.new.tag_update(@movie, '', params[:checked_tags])
        end

        @tags_already_checked = @movie.tag_list

        if params[:q].present?
            ajax_similar_tags_search = Movie.where("match(movie_title, contributor, contributor_comment) against(\"#{params[:q]}\")").map{|m| m.tag_list}.flatten.uniq
            @recommended_tags = (ajax_similar_tags_search - @tags_already_checked)
        else
            tag_ids = MoviesTags.where(:movie_id => params[:id]).map{|a| a.tag_id}
            recommended_tags_all = Movie.tag_counts_on(:tags).select{|x| tag_ids.include?(x.id)}.inject([]){|y, z| y << z.name ;y}
            @recommended_tags = (recommended_tags_all - @tags_already_checked)
        end

        respond_to do |format|
            format.html
            format.js
        end
    end

    def tag_update
        @movie = Movie.find(params[:id])

        respond_to do |format|
            if Movie.new.tag_update(@movie, params[:tag_list], params[:tag_check_box_list])
                format.html { redirect_to @movie, notice: "動画タグのデータベースへの登録に成功しました" }
            else
                format.html { redirect_to tag_edit_movie_path, alert: "動画タグのデータベースへの登録に失敗しました。再度入力してみてください" }
            end
        end
    end


  def contributor
    @movies = Movie.where(:contributor => current_user.contributor).page(params[:page])
  end


  # GET /movies
  # GET /movies.json
  def index
    if params[:search_query].present?
        @movies = Movie.new.movies_search(
                                params[:search_query],
                                params[:search_column],
                                params[:search_result_sort],
                                params[:page]
                                )
    elsif params[:tag].present?
        @movies = Movie.tagged_with(params[:tag]).page(params[:page])
    else
        @movies = Movie.page(params[:page])
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    next_play_counts = set_movie.play_counts += 1
    set_movie.update(:play_counts => next_play_counts)

    @movies = Movie.page(params[:page])

    @movie = Movie.find(params[:id])

    @vote = Vote.new.vote_like_dislike_count(@movie, current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit

  end


  # POST /movies
  # POST /movies.json
  def create
    respond_to do |format|
      if upload_movie_info = Movie.new.upload_movie_extract_info_and_save(params[:movie][:upfile], current_user)
            @movie = Movie.new(movie_params.merge!(upload_movie_info))

            if @movie.save
              MoviesTags.new.tag_recommend_database
              Movie.new.movie_thumbnails_create(File.join(Rails.root, upload_movie_info[:local_file_path]))
              format.html { redirect_to @movie, :notice => "#{@movie.file_basename}のアップロードに成功しました"}
              format.json { render action: 'show', status: :created, location: @movie }
            else
              flash[:notice]="動画メタデータのデータベースへの登録に失敗しました。再度実行してください"
              format.html { render action: 'new' }
              format.json { render json: @movie.errors, status: :unprocessable_entity }
            end
      else
        flash[:notice]="動画ファイルが指定されていないか、アップロードされたファイルは動画ではありません。再度動画ファイルを指定して実行してください"
        @movie = Movie.new(movie_params)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        MoviesTags.new.tag_recommend_database
        format.html { redirect_to @movie, notice: "動画メタデータのデータベースへの登録に成功しました" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    Movie.new.movie_and_thumbnails_destroy(File.join(Rails.root, @movie.local_file_path))
    MoviesTags.new.tag_recommend_database
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url }
      format.json { head :no_content }
    end
  end


  private

    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:file_name, :local_file_path, :file_basename, :movie_title, :contributor, :contributor_comment, :play_counts, :size, :path, :duration, :creation_time, :bitrate, :video_codec, :colorspace, :video_bitrate, :resolution, :audio_codec, :audio_channels, :audio_bitrate, :audio_sample_rate,
            :tag_list, :tag_check_box_list
            )
    end


end
