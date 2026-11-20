class CategoriesController < ApplicationController
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_back fallback_location: root_path, notice: "Category '#{@category.name}' created."
    else
      redirect_back fallback_location: root_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
