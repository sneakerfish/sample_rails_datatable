require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "name joins first and last name" do
    assert_equal "Ada Lovelace", contacts(:ada).name
    assert_equal "Ada", Contact.new(first_name: "Ada").name
  end
end
