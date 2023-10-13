class AddTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :auth_token, :string
    add_column :users, :auth_expiration, :datetime
  end
end
