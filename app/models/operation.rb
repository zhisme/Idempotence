class Operation < ApplicationRecord
  validates :total, numericality: { greater_than_or_equal_to: 0 }
end
