class VotesController < ApplicationController
  # like-dislike icons are there
  #http://dryicons.com/free-graphics/preview/like-dislike-buttons/#page

  def vote_up_down
    @movie = Movie.find(params[:movie_id])

    vote_condition = true  if params[:vote_up_down] == "vote_up"
    vote_condition = false if params[:vote_up_down] == "vote_down"

    vote_transaction_success_fail_check = Vote.new.vote_click_like_dislike_reverse(@movie, current_user, vote_condition)

    @vote = Vote.new.vote_like_dislike_count(@movie, current_user)

    respond_to do |format|
        if vote_transaction_success_fail_check
          format.html { redirect_to movie_path(@movie) }
          format.js { render }
        end
    end
  end

end




