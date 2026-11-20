require "test_helper"

class Api::V1::TemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template = templates(:coaching_template)
    @category_without_template = categories(:recruiting)
  end

  test "GET /api/v1/templates returns templates with embedded category" do
    get api_v1_templates_path, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Template.count, json.size

    item = json.find { |t| t["id"] == @template.id }
    assert_not_nil item["category"]
    assert_equal @template.category.name, item["category"]["name"]
  end

  test "GET /api/v1/templates filters by category_id" do
    get api_v1_templates_path, params: { category_id: @template.category_id }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal @template.id, json.first["id"]
  end

  test "GET /api/v1/templates/:id returns template" do
    get api_v1_template_path(@template), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @template.id, json["id"]
    assert_equal @template.body, json["body"]
    assert_equal @template.category.name, json["category"]["name"]
  end

  test "GET /api/v1/templates/:id returns 404 for unknown template" do
    get api_v1_template_path(id: 999999), as: :json
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Template not found", json["error"]
  end

  test "POST /api/v1/templates creates template with existing category" do
    assert_difference("Template.count", 1) do
      post api_v1_templates_path, params: {
        category_id: @category_without_template.id,
        body: "Hello {{name}}, we have exciting opportunities."
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal @category_without_template.id, json["category_id"]
    assert_equal @category_without_template.name, json["category"]["name"]
  end

  test "POST /api/v1/templates creates template with new_category_name" do
    assert_difference("Template.count", 1) do
      assert_difference("Category.count", 1) do
        post api_v1_templates_path, params: {
          new_category_name: "Strategic Partnerships",
          body: "Hello {{name}}, exploring partnership synergies."
        }, as: :json
      end
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Strategic Partnerships", json["category"]["name"]
  end

  test "POST /api/v1/templates fails when category already has template" do
    assert_no_difference("Template.count") do
      post api_v1_templates_path, params: {
        category_id: @template.category_id,
        body: "Duplicate template body"
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert_includes json["errors"], "Category already has a template"
  end

  test "PATCH /api/v1/templates/:id updates template body" do
    patch api_v1_template_path(@template), params: {
      body: "Updated greeting: Dear {{name}}, welcome!"
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated greeting: Dear {{name}}, welcome!", json["body"]
    assert_equal "Updated greeting: Dear {{name}}, welcome!", @template.reload.body
  end

  test "DELETE /api/v1/templates/:id destroys template" do
    assert_difference("Template.count", -1) do
      delete api_v1_template_path(@template), as: :json
    end

    assert_response :no_content
    assert_not Template.exists?(@template.id)
  end
end
