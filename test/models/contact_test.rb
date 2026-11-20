require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "valid contact" do
    contact = Contact.new(name: "John Doe", email: "john@example.com")
    assert contact.valid?
  end

  test "requires name" do
    contact = Contact.new(name: "")
    assert_not contact.valid?
    assert_includes contact.errors[:name], "can't be blank"
  end

  test "without_lead scope returns contacts without leads" do
    assert_includes Contact.without_lead, contacts(:clara)
    assert_not_includes Contact.without_lead, contacts(:alice)
  end

  test "search scope filters by name, email, company, and role" do
    assert_includes Contact.search("Walker"), contacts(:alice)
    assert_includes Contact.search("BuildCo"), contacts(:bob)
    assert_includes Contact.search("tardis"), contacts(:clara)
    assert_empty Contact.search("NonExistentXYZ")
  end
end
