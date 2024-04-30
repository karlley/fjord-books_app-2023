# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    @report_author = User.create!(email: 'foo@example.com', name: 'Foo', password: 'passoword')
    @report = Report.create!(user_id: @report_author.id, title: 'report', content: 'text')
  end

  # editable?
  test '日報の投稿者だった場合はtrue、日報の投稿者で無い場合はfalseを返す' do
    not_report_author = User.create!(email: 'bar@example.com', name: 'Bar', password: 'password')

    assert @report.editable?(@report_author)
    assert_not @report.editable?(not_report_author)
  end

  # created_on
  test '日報の作成年月日、作成曜日のみを返す' do
    assert_equal @report.created_at.to_date, @report.created_on
  end

  # save_mentions
  test '日報本文にメンション対象の日報URLが含まれていたらメンションが作成される' do
    assert_equal(0, ReportMention.count)
    assert_nil ReportMention.find_by(mentioned_by_id: @report.id)

    mentioning_report = Report.create!(user_id: @report_author.id, title: 'mention to report', content:
      "http://localhost:3000/reports/#{@report.id}")

    assert_equal(1, ReportMention.count)
    assert_not_nil ReportMention.find_by(mention_to_id: mentioning_report.id, mentioned_by_id: @report.id)
  end
end
