require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:alice)
  end

  test "should get index" do
    get contacts_path
    assert_response :success
    assert_select "h1", text: /Contacts/
  end

  test "should filter contacts by search query" do
    get contacts_path(q: "Alice")
    assert_response :success
    assert_select "div", text: "Alice Walker"

    get contacts_path(q: "NonExistent")
    assert_response :success
    assert_select "h3", text: "No contacts found"
  end

  test "should get new" do
    get new_contact_path
    assert_response :success
  end

  test "should create contact" do
    assert_difference("Contact.count", 1) do
      post contacts_path, params: {
        contact: {
          name: "David Miller",
          email: "david@example.com",
          company: "Miller Co",
          role: "Engineer",
          phone: "555-9999",
          linkedin_url: "https://linkedin.com/in/david",
          notes: "Met at meetup"
        }
      }
    end

    assert_redirected_to contacts_path
    follow_redirect!
    assert_select "div", text: /Contact David Miller was successfully created/
  end

  test "should get edit" do
    get edit_contact_path(@contact)
    assert_response :success
  end

  test "should update contact" do
    patch contact_path(@contact), params: {
      contact: {
        name: "Alice Updated",
        role: "Chief Executive Officer"
      }
    }

    assert_redirected_to contacts_path
    @contact.reload
    assert_equal "Alice Updated", @contact.name
    assert_equal "Chief Executive Officer", @contact.role
  end

  test "should destroy contact" do
    assert_difference("Contact.count", -1) do
      delete contact_path(@contact)
    end

    assert_redirected_to contacts_path
  end
end
