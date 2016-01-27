class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :file_name
      t.string :local_file_path
      t.string :file_basename
      t.string :movie_title
      t.text :contributor
      t.text :contributor_comment
      t.integer :rating
      t.integer :play_counts
      t.integer :size
      t.string :path
      t.float :duration
      t.datetime :creation_time
      t.integer :bitrate
      t.string :video_codec
      t.string :colorspace
      t.integer :video_bitrate
      t.string :resolution
      t.string :audio_codec
      t.string :audio_channels
      t.integer :audio_bitrate
      t.integer :audio_sample_rate

      t.references :user

      t.timestamps
    end
  end
end
