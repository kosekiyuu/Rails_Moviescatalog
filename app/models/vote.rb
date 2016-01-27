class Vote < ActiveRecord::Base
    belongs_to :movie
    belongs_to :user

    def vote_click_like_dislike_reverse(movie, current_user, vote_condition)
        vote_current_user = movie.vote.where(:user_id => current_user.id)

        if vote_current_user.empty?
            vote_transaction_success_fail_check = vote_current_user.build(:user_id => current_user.id, :vote => vote_condition).save
        elsif vote_current_user.where(:vote => !vote_condition).size == 1
            vote_transaction_success_fail_check = vote_current_user.map{|i| i.update_attributes(:vote => vote_condition)}
        else
            vote_transaction_success_fail_check = vote_current_user.map{|i| i.delete.save}.all?
        end

        vote_sum = movie.vote.inject(0){|x,y| x += y[:vote].to_s.gsub(/true/,'1').gsub(/false/,'-1').to_i ;x}
        vote_sum_transaction_check = movie.update_attributes({:rating => vote_sum})

        [vote_transaction_success_fail_check, vote_sum_transaction_check].all?
    end

    def vote_like_dislike_count(movie, current_user)
        {
        :vote_like_count => movie.vote.where(:vote => true).count,
        :vote_dislike_count => movie.vote.where(:vote => false).count,
        :vote_user_like => movie.vote.where(:user_id => current_user.try(:id), :vote => true),
        :vote_user_dislike => movie.vote.where(:user_id => current_user.try(:id), :vote => false),
        }
    end

end
