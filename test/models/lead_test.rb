require "test_helper"

class LeadTest < ActiveSupport::TestCase
  test "valid lead" do
    lead = Lead.new(
      contact: contacts(:clara),
      category: categories(:recruiting),
      status: :backlog,
      notes: "Clara lead"
    )
    assert lead.valid?
  end

  test "enforces 1:1 relationship per contact" do
    duplicate_lead = Lead.new(
      contact: contacts(:alice),
      category: categories(:recruiting),
      status: :backlog
    )
    assert_not duplicate_lead.valid?
    assert_includes duplicate_lead.errors[:contact_id], "has already been taken"
  end

  test "allows only valid statuses" do
    lead = Lead.new(contact: contacts(:clara), category: categories(:recruiting), status: "invalid_status")
    assert_not lead.valid?
    assert_includes lead.errors[:status], "is not included in the list"
  end

  test "creates new category inline via new_category_name" do
    lead = Lead.new(
      contact: contacts(:clara),
      new_category_name: "Strategic Consulting",
      status: :in_progress
    )
    assert lead.valid?
    assert_equal "Strategic Consulting", lead.category.name
  end
end
