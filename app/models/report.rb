# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :mentioners, class_name: 'Mention', foreign_key: 'mention_source_id', dependent: :destroy, inverse_of:
    :mention_source
  has_many :mentionees, class_name: 'Mention', foreign_key: 'mention_target_id', dependent: :destroy, inverse_of:
    :mention_target
  has_many :mentioning_reports, through: :mentioners, source: :mention_target
  has_many :mentioned_reports, through: :mentionees, source: :mention_source

  validates :title, presence: true
  validates :content, presence: true
  validate :valid_mention_target

  after_create :update_mentions!
  after_update :update_mentions!

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  private

  def extract_mention_target_ids
    url_regexp = %r{http://localhost:3000/reports/([0-9０-９]+)(?!.*?/edit)}
    content.scan(url_regexp).map do |match|
      raw_report_id = match.first
      numeric_report_id = raw_report_id&.tr('０-９', '0-9')&.to_i
      numeric_report_id || raw_report_id
    end.uniq
  end

  def update_mentions!
    mention_target_ids = extract_mention_target_ids
    new_mention_ids = mention_target_ids - mentioning_report_ids
    obsolete_mention_ids = mentioning_report_ids - mention_target_ids
    obsolete_mentions = mentioners.where(mention_target_id: obsolete_mention_ids)

    transaction do
      new_mention_ids.each do |new_mention_id|
        mentioners.create!(mention_target_id: new_mention_id)
      end

      obsolete_mentions.each(&:destroy!)
    end
  end

  def valid_mention_target
    new_mention_ids = extract_mention_target_ids
    return if Report.where(id: new_mention_ids).pluck(:id) == new_mention_ids

    errors.add(:content, I18n.t('errors.messages.not_found', model: model_name.human))
  end
end
