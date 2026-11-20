require "test_helper"

class Api::V1::LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lead = leads(:alice_lead)
    @contact_without_lead = contacts(:clara)
    @category = categories(:coaching)
  end

  test "GET /api/v1/leads returns leads with embedded contact and category" do
    get api_v1_leads_path, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Lead.count, json.size

    first_lead = json.find { |l| l["id"] == @lead.id }
    assert_not_nil first_lead["contact"]
    assert_equal @lead.contact.name, first_lead["contact"]["name"]
    assert_not_nil first_lead["category"]
    assert_equal @lead.category.name, first_lead["category"]["name"]
    assert_equal "in_progress", first_lead["status"]
    assert_equal "In-Progress", first_lead["status_label"]
  end

  test "GET /api/v1/leads filters by status" do
    get api_v1_leads_path, params: { status: "in_progress" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json.all? { |l| l["status"] == "in_progress" }
    assert_includes json.map { |l| l["id"] }, @lead.id
  end

  test "GET /api/v1/leads filters by category_id" do
    get api_v1_leads_path, params: { category_id: @category.id }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json.all? { |l| l["category_id"] == @category.id }
  end

  test "GET /api/v1/leads filters by contact_id" do
    get api_v1_leads_path, params: { contact_id: @lead.contact_id }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal @lead.id, json.first["id"]
  end

  test "GET /api/v1/leads pagination limit and offset" do
    get api_v1_leads_path, params: { limit: 1, offset: 0 }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal "1", response.headers["X-Limit"]
    assert_equal "0", response.headers["X-Offset"]
  end

  test "GET /api/v1/leads filters by search query q" do
    get api_v1_leads_path, params: { q: "Alice" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal "Alice Walker", json.first["contact"]["name"]
  end

  test "GET /api/v1/leads/:id returns lead with associations" do
    get api_v1_lead_path(@lead), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @lead.id, json["id"]
    assert_equal @lead.contact_id, json["contact"]["id"]
    assert_equal @lead.category_id, json["category"]["id"]
  end

  test "GET /api/v1/leads/:id returns 404 for unknown lead" do
    get api_v1_lead_path(id: 999999), as: :json
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Lead not found", json["error"]
  end

  test "POST /api/v1/leads creates lead with bare payload" do
    assert_difference("Lead.count", 1) do
      post api_v1_leads_path, params: {
        contact_id: @contact_without_lead.id,
        category_id: @category.id,
        status: "backlog",
        notes: "Brand new lead"
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal @contact_without_lead.id, json["contact_id"]
    assert_equal "backlog", json["status"]
    assert_equal "Brand new lead", json["notes"]
    assert_equal @contact_without_lead.name, json["contact"]["name"]
  end

  test "POST /api/v1/leads creates lead with new_category_name" do
    assert_difference("Lead.count", 1) do
      assert_difference("Category.count", 1) do
        post api_v1_leads_path, params: {
          lead: {
            contact_id: @contact_without_lead.id,
            new_category_name: "FinTech Consulting",
            status: "in_progress"
          }
        }, as: :json
      end
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "FinTech Consulting", json["category"]["name"]
    assert_equal "in_progress", json["status"]
  end

  test "POST /api/v1/leads fails if contact already has a lead" do
    assert_no_difference("Lead.count") do
      post api_v1_leads_path, params: {
        contact_id: @lead.contact_id,
        category_id: @category.id
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert_includes json["errors"], "Contact has already been taken"
  end

  test "POST /api/v1/leads fails with invalid status" do
    assert_no_difference("Lead.count") do
      post api_v1_leads_path, params: {
        contact_id: @contact_without_lead.id,
        category_id: @category.id,
        status: "not_a_real_status"
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
  end

  test "PATCH /api/v1/leads/:id updates status and notes" do
    patch api_v1_lead_path(@lead), params: {
      status: "done",
      notes: "Deal closed successfully"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "done", json["status"]
    assert_equal "Done", json["status_label"]
    assert_equal "Deal closed successfully", json["notes"]
    assert_equal "done", @lead.reload.status
  end

  test "DELETE /api/v1/leads/:id deletes lead" do
    assert_difference("Lead.count", -1) do
      delete api_v1_lead_path(@lead), as: :json
    end

    assert_response :no_content
    assert_not Lead.exists?(@lead.id)
  end
end
