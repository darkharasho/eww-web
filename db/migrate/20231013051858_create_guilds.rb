class CreateGuilds < ActiveRecord::Migration[7.1]
  def change
    create_table :guilds do |t|
      t.string :uid,              null: false, default: ""
      t.string :name,             null: false, default: ""
      t.string :remote_image_url,              default: ""
      t.timestamps
    end
  end
end
