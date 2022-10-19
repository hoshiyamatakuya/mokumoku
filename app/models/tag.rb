class Tag < ApplicationRecord
  has_many :event_tags,dependent: :destroy, foreign_key: 'tag_id'
  # タグは複数の投稿を持つ　それは、post_tagsを通じて参照できる
  has_many :events,through: :event_tags

  validates :name, uniqueness: true, presence: true
end
