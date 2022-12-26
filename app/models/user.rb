class User < ApplicationRecord
    has_many :posts, dependent: :destroy
    has_many :comments, dependent: :destroy
    validates :email, uniqueness: true
    validates :name, uniqueness: true
    validates :name, presence: true
    validates :password, presence: true
    validates :email, presence: true
end
