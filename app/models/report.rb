# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :active_mentions, class_name: 'Mention', foreign_key: 'mention_source_id', dependent: :destroy, inverse_of: :mention_source
  has_many :passive_mentions, class_name: 'Mention', foreign_key: 'mention_target_id', dependent: :destroy, inverse_of: :mention_target
  has_many :mentioning_reports, through: :active_mentions, source: :mention_target
  has_many :mentioned_reports, through: :passive_mentions, source: :mention_source

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end
end
