class Config < ApplicationRecord
  self.table_name = "config"

  belongs_to :guild, foreign_key: :guild_id
end
