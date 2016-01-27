class CreateMoviesTags < ActiveRecord::Migration
  def change
    create_table :movies_tags do |t|
      t.references :movie, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
