require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category_with_leads = categories(:coaching)
    @category_without_leads = categories(:recruiting)
  end

  test "GET /api/v1/categories returns list of categories" do
    get api_v1_categories_path, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Category.count, json.size

    coaching = json.find { |c| c["id"] == @category_with_leads.id }
    assert coaching["has_template"]
    assert_not_nil coaching["template"]
  end

  test "GET /api/v1/categories with search query q" do
    get api_v1_categories_path, params: { q: "Coach" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.size
    assert_equal "Coaching", json.first["name"]
  end

  test "GET /api/v1/categories/:id returns category" do
    get api_v1_category_path(@category_with_leads), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @category_with_leads.id, json["id"]
    assert_equal "Coaching", json["name"]
    assert json["has_template"]
  end

  test "GET /api/v1/categories/:id returns 404 for unknown category" do
    get api_v1_category_path(id: 999999), as: :json
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Category not found", json["error"]
  end

  test "POST /api/v1/categories creates category" do
    assert_difference("Category.count", 1) do
      post api_v1_categories_path, params: { name: "Advisory" }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Advisory", json["name"]
  end

  test "POST /api/v1/categories fails with duplicate or blank name" do
    assert_no_difference("Category.count") do
      post api_v1_categories_path, params: { name: "Coaching" }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert_includes json["errors"], "Name has already been taken"
  end

  test "PATCH /api/v1/categories/:id updates category" do
    patch api_v1_category_path(@category_without_leads), params: { name: "Executive Search" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "Executive Search", json["name"]
    assert_equal "Executive Search", @category_without_leads.reload.name
  end

  test "DELETE /api/v1/categories/:id destroys empty category" do
    assert_difference("Category.count", -1) do
      delete api_v1_category_path(@category_without_leads), as: :json
    end

    assert_response :no_content
    assert_not Category.exists?(@category_without_leads.id)
  end

  test "DELETE /api/v1/categories/:id fails if category has leads" do
    assert_no_difference("Category.count") do
      delete api_v1_category_path(@category_with_leads), as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert json["errors"].any? { |e| e =~ /Cannot delete record because dependent leads exist/ }
  end
end
