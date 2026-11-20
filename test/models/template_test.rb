require "test_helper"

class TemplateTest < ActiveSupport::TestCase
  test "valid template" do
    template = Template.new(category: categories(:recruiting), body: "Recruiting template text")
    assert template.valid?
  end

  test "requires body" do
    template = Template.new(category: categories(:recruiting), body: "")
    assert_not template.valid?
    assert_includes template.errors[:body], "can't be blank"
  end

  test "enforces unique template per category" do
    duplicate = Template.new(category: categories(:coaching), body: "Another body")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:category_id], "already has a template"
  end

  test "creates new category inline via new_category_name" do
    template = Template.new(new_category_name: "Partnerships", body: "Hello partner")
    assert template.valid?
    assert_equal "Partnerships", template.category.name
  end
end
