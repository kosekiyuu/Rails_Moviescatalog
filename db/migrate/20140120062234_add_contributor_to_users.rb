class AddContributorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contributor, :string, :unique => true, :null => false
  end

end
