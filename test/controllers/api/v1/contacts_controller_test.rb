require "test_helper"

class Api::V1::ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:alice)
    @contact_without_lead = contacts(:clara)
  end

  test "GET /api/v1/contacts returns contacts with pagination headers" do
    get api_v1_contacts_path, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Contact.count, json.size
    assert response.headers["X-Total-Count"].present?
    assert_equal "50", response.headers["X-Limit"]
    assert_equal "0", response.headers["X-Offset"]

    # Verify embedded lead info
    alice_json = json.find { |c| c["id"] == @contact.id }
    assert alice_json["has_lead"]
    assert_not_nil alice_json["lead"]
    assert_equal "in_progress", alice_json["lead"]["status"]

    clara_json = json.find { |c| c["id"] == @contact_without_lead.id }
    assert_not clara_json["has_lead"]
    assert_nil clara_json["lead"]
  end

  test "GET /api/v1/contacts with search query" do
    get api_v1_contacts_path, params: { q: "Alice" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal "Alice Walker", json.first["name"]
  end

  test "GET /api/v1/contacts with sorting" do
    get api_v1_contacts_path, params: { sort: "name", order: "desc" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    names = json.map { |c| c["name"] }
    assert_equal names.sort.reverse, names
  end

  test "GET /api/v1/contacts/:id returns contact" do
    get api_v1_contact_path(@contact), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @contact.id, json["id"]
    assert_equal @contact.name, json["name"]
    assert_equal @contact.email, json["email"]
    assert json["has_lead"]
  end

  test "GET /api/v1/contacts/:id returns 404 for unknown contact" do
    get api_v1_contact_path(id: 999999), as: :json
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Contact not found", json["error"]
  end

  test "POST /api/v1/contacts creates contact with wrapped payload" do
    assert_difference("Contact.count", 1) do
      post api_v1_contacts_path, params: {
        contact: {
          name: "Ada Lovelace",
          email: "ada@example.com",
          company: "Analytical Engine",
          role: "Programmer"
        }
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Ada Lovelace", json["name"]
    assert_equal "ada@example.com", json["email"]
  end

  test "POST /api/v1/contacts creates contact with bare payload" do
    assert_difference("Contact.count", 1) do
      post api_v1_contacts_path, params: {
        name: "Charles Babbage",
        email: "charles@example.com",
        company: "Difference Engine"
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Charles Babbage", json["name"]
  end

  test "POST /api/v1/contacts fails with validation errors" do
    assert_no_difference("Contact.count") do
      post api_v1_contacts_path, params: { name: "" }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PATCH /api/v1/contacts/:id updates contact" do
    patch api_v1_contact_path(@contact), params: {
      company: "Acme Corp International"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Acme Corp International", json["company"]
    assert_equal "Acme Corp International", @contact.reload.company
  end

  test "DELETE /api/v1/contacts/:id deletes contact" do
    assert_difference("Contact.count", -1) do
      delete api_v1_contact_path(@contact_without_lead), as: :json
    end

    assert_response :no_content
    assert_not Contact.exists?(@contact_without_lead.id)
  end
end
