class PlayerRequest < ApplicationRecord
  validates :name,        presence: true
end
