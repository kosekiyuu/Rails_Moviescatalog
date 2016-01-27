class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.boolean :vote
      t.references :movie
      t.references :user

      t.timestamps
    end
  end
end
