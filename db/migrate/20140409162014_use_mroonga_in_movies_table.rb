class UseMroongaInMoviesTable < ActiveRecord::Migration
  def change
        execute <<-SQL
        ALTER TABLE movies
          ENGINE = mroonga COMMENT = 'parser = "TokenMecab";' DEFAULT CHARSET utf8
        SQL

        execute <<-SQL
        ALTER TABLE movies
          ADD FULLTEXT INDEX index_movies (movie_title, contributor, contributor_comment);
        SQL


        execute <<-SQL
        ALTER TABLE tags
          ENGINE = mroonga COMMENT = 'parser = "TokenMecab";' DEFAULT CHARSET utf8
        SQL

        execute <<-SQL
        ALTER TABLE tags
          ADD FULLTEXT INDEX index_tags (name);
        SQL
  end
end
