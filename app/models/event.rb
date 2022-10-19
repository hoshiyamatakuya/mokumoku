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
  has_many :event_tags,dependent: :destroy
  has_many :tags,through: :event_tags

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
  def save_tag(sent_tags)
    # タグが存在していれば、タグの名前を配列として全て取得
      current_tags = self.tags.pluck(:name) unless self.tags.nil?
      # 現在取得したタグから送られてきたタグを除いてoldtagとする
      old_tags = current_tags - sent_tags
      # 送信されてきたタグから現在存在するタグを除いたタグをnewとする
      new_tags = sent_tags - current_tags
  
      # 古いタグを消す
      old_tags.each do |old|
        self.tags.delete　Tag.find_by(name: old)
      end
  
      # 新しいタグを保存
      new_tags.each do |new|
        new_post_tag = Tag.find_or_create_by(name: new)
        self.tags << new_post_tag
     end
  end
end
