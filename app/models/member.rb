class Member < ApplicationRecord
  self.table_name = "member"

  belongs_to :user
end
