class AddMemberIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :member, :user_id, :int
  end
end
