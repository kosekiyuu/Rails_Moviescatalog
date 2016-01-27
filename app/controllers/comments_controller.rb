class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @movie = Movie.find(params[:comment][:commentable_id])
    @user_who_commented = current_user
    @comment = Comment.build_from(@movie, @user_who_commented.id, params[:comment][:body] )

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @movie}
        format.json { render :json => @movie, :status => :created, :location => @movie }
      end
    end
  end

  def destroy
    @movie = Movie.find(params[:movie_id])
    @comment = @movie.comment_threads.find(params[:id])

    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to @movie}
        format.json { render :json => @movie, :status => :created, :location => @movie }
      end
    end
  end

end
