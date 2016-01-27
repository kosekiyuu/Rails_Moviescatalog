class MoviesTags < ActiveRecord::Base
    belongs_to :movie
    belongs_to :tag

    def tag_recommend_database
        group_tag_array = Movie.all.map{|y| y.tag_list}
        group_tag_array.map{|c| c.reject!{|d| d.blank?}}
        group_tag_array.map{|e| e.select!{|f| f.size > 1}}

        movies_hash = Movie.select('id, movie_title, contributor_comment').map{|z| z.attributes.merge({'tag_list' => z.tag_list})}


        movie_recommended_tag = []

        movies_hash.each do |movie|
            movie_content = movie['tag_list'].inject(String.new){|f,g| f += g ;f}
            movie_content += movie['movie_title']
            movie_content += movie['contributor_comment']

            if group_tag_array.select{|n| n.map{|m| movie_content.include?(m) }.any?}.flatten.uniq.size > 20
                tag_word_include_group = group_tag_array.flatten.uniq.select{|m| movie_content.include?(m)}.inject(Hash.new(0)){|a, b| a[b] += 1 ;a}
            else
                tag_word_include_group = group_tag_array.select{|n| n.map{|m| movie_content.include?(m) }.any?}.flatten.inject(Hash.new(0)){|a, b| a[b] += 1 ;a}
            end

            movie_recommended_tag.push({
                :movie_id => movie['id'],
                :movie_title => movie['movie_title'],
                :tag_group => tag_word_include_group
                })

        end

        #pp movie_recommended_tag

        all_tags = Movie.tag_counts_on(:tags)

        movie_tag_relation = []
        movie_recommended_tag.each do |x|
            x[:tag_group].each do |w|
                all_tags.each do |u|
                    if u.name == w[0]
                        movie_tag_relation << {
                            :movie_id => x[:movie_id],
                            :tag_id => u.id
                            }
                    end
                end
            end
        end

        MoviesTags.all.delete_all
        movie_tag_relation.map{|v| MoviesTags.create(v) }
    end

end
