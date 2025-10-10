# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # name_or_email
  test 'ユーザ名が未入力の場合はメールアドレスがユーザ名になる' do
    user = User.new(email: 'taro@example.com', name: '')
    assert_equal 'taro@example.com', user.name_or_email

    user.name = '太郎'
    assert_equal '太郎', user.name_or_email
  end
end
