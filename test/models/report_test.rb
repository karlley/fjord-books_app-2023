# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    @report_author = User.create!(email: 'taro@example.com', name: '太郎', password: 'passoword')
    @report = Report.create!(user_id: @report_author.id, title: 'report', content: 'text')
  end

  # editable?
  test '日報の投稿者だった場合はtrue、日報の投稿者で無い場合はfalseを返す' do
    not_report_author = User.create!(email: 'jiro@example.com', name: '次郎', password: 'password')

    assert @report.editable?(@report_author)
    assert_not @report.editable?(not_report_author)
  end

  # created_on
  test '日付オブジェクトで日報の作成年月日のみを返す' do
    assert_instance_of Date, @report.created_on
    created_at = @report.created_at
    expected_format = %r{\A#{created_at.year}/#{format('%02d', created_at.month)}/#{format('%02d', created_at.day)}\z}
    formatted_date = I18n.l(@report.created_on)
    assert_match expected_format, formatted_date
  end

  # save_mentions、日報作成、メンション作成
  test '本文にメンション対象の日報URLを含む日報を作成するとメンションが作成される' do
    assert_equal(0, @report.mentioned_reports.count)

    mentioning_report = Report.create!(user_id: @report_author.id, title: 'mention to report', content:
      "http://localhost:3000/reports/#{@report.id}")

    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)
  end

  # save_mentions、日報更新、メンション追加
  test '本文にメンション対象の日報URLを追加後に日報の更新を行うとメンションが作成される' do
    mentioning_report = Report.create!(user_id: @report_author.id, title: 'report', content: 'メンションは未作成')
    assert_equal(0, @report.mentioned_reports.count)
    assert_equal(0, mentioning_report.mentioning_reports.count)

    mentioning_report.update!(content: "http://localhost:3000/reports/#{@report.id}")
    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)
  end

  # save_mentions、日報更新、メンション削除
  test '本文のメンション対象の日報URLを削除後に日報の更新を行うとメンションが削除される' do
    mentioning_report = Report.create!(user_id: @report_author.id, title: 'report', content: "http://localhost:3000/reports/#{@report.id}")
    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)

    mentioning_report.update!(content: 'メンションの削除')
    assert_equal(0, @report.mentioned_reports.count)
    assert_equal(0, mentioning_report.mentioning_reports.count)
  end

  # save_mentions、日報更新、メンション未更新
  test '本文のメンション対象の日報URLを変更せずに日報更新を行うとメンションは作成されない' do
    mentioning_report = Report.create!(user_id: @report_author.id, title: 'report', content: "http://localhost:3000/reports/#{@report.id}")
    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)

    mentioning_report.update!(content: "http://localhost:3000/reports/#{@report.id} メンションは未更新")
    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)
  end

  test '本文にメンション対象の日報URLが含まれた日報を削除するとメンションが削除される' do
    mentioning_report = Report.create!(user_id: @report_author.id, title: 'report', content: "http://localhost:3000/reports/#{@report.id}")
    assert_equal(1, @report.mentioned_reports.count)
    assert_equal(1, mentioning_report.mentioning_reports.count)

    mentioning_report.update!(content: 'メンションを削除')
    assert_equal(0, @report.mentioned_reports.count)
    assert_equal(0, mentioning_report.mentioning_reports.count)
  end
end
