# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    @report = reports(:first_report)

    visit root_url
    fill_in 'Eメール', with: 'alice@example.com'
    fill_in 'パスワード', with: 'password'
    click_on 'ログイン'
    assert_text 'ログインしました。'
  end

  test 'visiting the index' do
    visit reports_url
    assert_selector 'h1', text: '日報の一覧'
    assert_selector "div#report_#{@report.id} p", text: @report.title
    assert_selector "div#report_#{@report.id} p", text: @report.content
    assert_selector "div#report_#{@report.id} p", text: @report.user.name_or_email
    assert_selector "div#report_#{@report.id} p", text: I18n.l(@report.created_on)
  end

  test 'should create report' do
    visit new_report_url
    assert_selector 'h1', text: '日報の新規作成'

    fill_in 'タイトル', with: '2回目の日報'
    fill_in '内容', with: '今日も勉強できた！'
    click_button '登録する'
    assert_text '日報が作成されました。'
    created_report = Report.last
    assert_selector 'h1', text: '日報の詳細'
    assert_selector "div#report_#{created_report.id} p", text: '2回目の日報'
    assert_selector "div#report_#{created_report.id} p", text: '今日も勉強できた！'
    assert_selector "div#report_#{created_report.id} p", text: created_report.user.name_or_email
    assert_selector "div#report_#{created_report.id} p", text: I18n.l(created_report.created_on)
  end

  test 'should update Report' do
    visit edit_report_url(@report)
    assert_selector 'h1', text: '日報の編集'
    assert_selector "input#report_title[value=#{@report.title}]"
    assert_selector 'textarea#report_content', text: @report.content

    fill_in 'タイトル', with: 'タイトルの編集'
    fill_in '内容', with: '内容の編集'
    click_on '更新する'
    assert_text '日報が更新されました。'
    assert_selector "div#report_#{@report.id} p", text: 'タイトルの編集'
    assert_selector "div#report_#{@report.id} p", text: '内容の編集'
    assert_selector "div#report_#{@report.id} p", text: @report.user.name_or_email
    assert_selector "div#report_#{@report.id} p", text: I18n.l(@report.created_on)
  end

  test 'should destroy Report' do
    visit report_url(@report)
    assert_selector "div#report_#{@report.id} p", text: @report.title
    assert_selector "div#report_#{@report.id} p", text: @report.content
    assert_selector "div#report_#{@report.id} p", text: @report.user.name_or_email
    assert_selector "div#report_#{@report.id} p", text: I18n.l(@report.created_on)

    click_on 'この日報を削除'
    assert_text '日報が削除されました。'
    assert_no_selector "div#report_#{@report.id} p", text: @report.title
    assert_no_selector "div#report_#{@report.id} p", text: @report.content
    assert_no_selector "div#report_#{@report.id} p", text: @report.user.name_or_email
    assert_no_selector "div#report_#{@report.id} p", text: I18n.l(@report.created_on)
  end
end
