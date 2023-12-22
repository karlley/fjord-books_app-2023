# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :mention_source, class_name: 'Report'
  belongs_to :mention_target, class_name: 'Report'

  validates :mention_source_id, uniqueness: { scope: :mention_target_id }
end
