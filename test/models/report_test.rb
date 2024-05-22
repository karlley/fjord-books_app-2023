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
    year_month_day = [2024, 1, 1]
    @report.update!(created_at: Time.zone.local(*year_month_day))
    expected_date = Date.new(*year_month_day)
    assert_equal expected_date, @report.created_on
  end

  # save_mentions、日報作成、メンション作成
  test '本文にメンション対象の日報URLを含む日報を作成するとメンションが作成される' do
    assert_equal(0, @report.mentioned_reports.count)

    mentioning_report = Report.create!(user: @report_author, title: 'mention to report', content:
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
