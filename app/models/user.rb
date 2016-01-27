class User < ActiveRecord::Base
    has_many :movies, :dependent => :destroy
    has_many :comments, :dependent => :destroy
    has_many :votes, :dependent => :destroy

    validates_presence_of [:contributor, :email]
    validates_uniqueness_of :email

    accepts_nested_attributes_for :movies

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

end
