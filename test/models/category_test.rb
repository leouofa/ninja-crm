require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "valid category" do
    cat = Category.new(name: "Advisory")
    assert cat.valid?
  end

  test "requires name" do
    cat = Category.new(name: "")
    assert_not cat.valid?
    assert_includes cat.errors[:name], "can't be blank"
  end

  test "enforces case-insensitive unique name" do
    duplicate = Category.new(name: "coaching")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end
end
