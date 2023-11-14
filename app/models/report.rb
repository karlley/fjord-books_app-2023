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

  def extract_mention_target_ids
    pattern = %r{http://localhost:3000/reports/([0-9０-９]+)}
    content.scan(pattern).map do |match|
      match_value = match.first
      converted_value = match_value&.tr('０-９', '0-9')&.to_i
      converted_value || match_value
    end.uniq
  end

  def create_mentions
    create_mention_target_ids = extract_mention_target_ids
    create_mention_target_ids.each do |target_id|
      active_mentions.create(mention_target_id: target_id)
    end
  end

  def update_mentions
    mention_target_ids = extract_mention_target_ids
    create_mention_target_ids = mention_target_ids - mentioning_report_ids
    delete_mention_target_ids = mentioning_report_ids - mention_target_ids

    transaction do
      create_mention_target_ids.each do |target_id|
        active_mentions.create!(mention_target_id: target_id)
      end
      delete_mention_target_ids.each do |target_id|
        target_mention = active_mentions.find_by!(mention_target_id: target_id)
        target_mention.destroy!
      end
    end
  end
end
