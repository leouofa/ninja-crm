require "test_helper"

class Api::V1::BaseControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/openapi.json returns valid JSON spec" do
    get api_v1_openapi_path
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "3.1.0", json["openapi"]
    assert_equal "Ninja CRM API", json["info"]["title"]
    assert json["paths"]["/contacts"].present?
    assert json["paths"]["/leads"].present?
    assert json["paths"]["/categories"].present?
    assert json["paths"]["/templates"].present?
  end
end
