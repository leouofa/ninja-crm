require "test_helper"

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template = templates(:coaching_template)
  end

  test "should get index" do
    get templates_path
    assert_response :success
    assert_select "h1", text: /Message Templates/
  end

  test "should get new" do
    get new_template_path
    assert_response :success
  end

  test "should create template" do
    assert_difference("Template.count", 1) do
      post templates_path, params: {
        template: {
          category_id: categories(:recruiting).id,
          body: "Hello {{name}}, recruiting opportunity."
        }
      }
    end

    assert_redirected_to templates_path
  end

  test "should create template with new category" do
    assert_difference("Category.count", 1) do
      assert_difference("Template.count", 1) do
        post templates_path, params: {
          template: {
            new_category_name: "Advisory",
            body: "Advisory message template"
          }
        }
      end
    end

    assert_redirected_to templates_path
    assert_equal "Advisory", Template.last.category.name
  end

  test "should update existing template if category already has one" do
    assert_no_difference("Template.count") do
      post templates_path, params: {
        template: {
          category_id: categories(:coaching).id,
          body: "Updated coaching template via modal"
        }
      }
    end

    assert_redirected_to templates_path
    @template.reload
    assert_equal "Updated coaching template via modal", @template.body
  end

  test "should get edit" do
    get edit_template_path(@template)
    assert_response :success
  end

  test "should update template" do
    patch template_path(@template), params: {
      template: {
        body: "New updated body"
      }
    }

    assert_redirected_to templates_path
    @template.reload
    assert_equal "New updated body", @template.body
  end

  test "should destroy template" do
    assert_difference("Template.count", -1) do
      delete template_path(@template)
    end

    assert_redirected_to templates_path
  end
end
