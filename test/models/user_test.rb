# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # name_or_email
  test 'ユーザ名が未入力の場合はメールアドレスがユーザ名になる' do
    user = User.new(email: 'foo@example.com', name: '')
    assert_equal 'foo@example.com', user.name_or_email

    user.name = 'Foo Bar'
    assert_equal 'Foo Bar', user.name_or_email
  end
end
