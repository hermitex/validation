class Person < ApplicationRecord
  validates :username, presence: true # no blank
  validates :email, presence: true, uniqueness: true # no blank, no duplicates
  validates :phone, length: {is: 10} # must be EXACTLY 10 characters long
end

