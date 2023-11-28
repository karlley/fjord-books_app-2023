# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :mention_source, class_name: 'Report'
  belongs_to :mention_target, class_name: 'Report'

  validate :valid_mention_target
  validates :mention_source_id, uniqueness: { scope: :mention_target_id }

  private

  def valid_mention_target
    return if Report.exists?(id: mention_target_id)

    mention_source.errors.add(:content, I18n.t('errors.messages.not_found', model: Report.model_name.human))
  end
end
