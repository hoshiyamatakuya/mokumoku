# frozen_string_literal: true

class Event < ApplicationRecord
  include Notifiable
  belongs_to :prefecture
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, class_name: 'User', source: :user
  has_many :attendances, dependent: :destroy, class_name: 'EventAttendance'
  has_many :attendees, through: :attendances, class_name: 'User', source: :user
  has_many :bookmarks, dependent: :destroy
  has_one_attached :thumbnail

  scope :future, -> { where('held_at > ?', Time.current) }
  scope :past, -> { where('held_at <= ?', Time.current) }

  with_options presence: true do
    validates :title
    validates :content
    validates :held_at
  end

  def past?
    held_at < Time.current
  end

  def future?
    !past?
  end
end
