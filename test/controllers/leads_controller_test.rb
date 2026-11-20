require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lead = leads(:alice_lead)
  end

  test "should get index" do
    get leads_path
    assert_response :success
    assert_select "h1", text: /Leads Pipeline/
    assert_select "h3", text: "Backlog"
    assert_select "h3", text: "In-Progress"
    assert_select "h3", text: "Done"
  end

  test "should filter index by category" do
    get leads_path(category_id: categories(:coaching).id)
    assert_response :success
    assert_select "h4 a", text: @lead.contact.name
    assert_select "a[href=?]", contacts_path(q: @lead.contact.name)
  end

  test "should get archived view on index" do
    @lead.update!(status: :archived)
    get leads_path(view: "archived")
    assert_response :success
    assert_select "h4 a", text: @lead.contact.name
    assert_select "button", text: /Restore to Done/
  end

  test "should archive lead" do
    @lead.update!(status: :done)
    patch move_lead_path(@lead), params: { status: "archived" }
    assert_redirected_to leads_path
    @lead.reload
    assert_equal "archived", @lead.status
  end

  test "should restore archived lead to done" do
    @lead.update!(status: :archived)
    patch move_lead_path(@lead), params: { status: "done" }
    assert_redirected_to leads_path
    @lead.reload
    assert_equal "done", @lead.status
  end

  test "should get new" do
    get new_lead_path
    assert_response :success
  end

  test "should get new with pre-selected contact" do
    get new_lead_path(contact_id: contacts(:clara).id, status: "in_progress")
    assert_response :success
  end

  test "should create lead" do
    assert_difference("Lead.count", 1) do
      post leads_path, params: {
        lead: {
          contact_id: contacts(:clara).id,
          category_id: categories(:recruiting).id,
          status: "backlog",
          notes: "Initial discovery phase"
        }
      }
    end

    assert_redirected_to leads_path
  end

  test "should create lead with new category name" do
    assert_difference("Category.count", 1) do
      assert_difference("Lead.count", 1) do
        post leads_path, params: {
          lead: {
            contact_id: contacts(:clara).id,
            new_category_name: "Strategic Advisory",
            status: "in_progress",
            notes: "Advisory client"
          }
        }
      end
    end

    assert_redirected_to leads_path
    assert_equal "Strategic Advisory", Lead.last.category.name
  end

  test "should get edit" do
    get edit_lead_path(@lead)
    assert_response :success
  end

  test "should update lead" do
    patch lead_path(@lead), params: {
      lead: {
        status: "done",
        notes: "Completed deal successfully"
      }
    }

    assert_redirected_to leads_path
    @lead.reload
    assert_equal "done", @lead.status
    assert_equal "Completed deal successfully", @lead.notes
  end

  test "should move lead status via patch" do
    patch move_lead_path(@lead), params: { status: "done" }, as: :json
    assert_response :success
    @lead.reload
    assert_equal "done", @lead.status
  end

  test "should destroy lead without destroying contact" do
    contact = @lead.contact
    assert_difference("Lead.count", -1) do
      assert_no_difference("Contact.count") do
        delete lead_path(@lead)
      end
    end

    assert_redirected_to leads_path
  end

  test "should render copy notes button when lead has notes" do
    @lead.update!(notes: "Crucial project note")
    get leads_path
    assert_response :success
    assert_select "div[data-controller='clipboard'][data-clipboard-content-value='Crucial project note']" do
      assert_select "button[title='Copy Notes']"
    end
  end

  test "should not render copy notes button when lead has blank notes" do
    @lead.update!(notes: nil)
    leads(:bob_lead).update!(notes: "")
    get leads_path
    assert_response :success
    assert_select "button[title='Copy Notes']", count: 0
  end
end
