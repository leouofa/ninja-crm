class TemplatesController < ApplicationController
  before_action :set_template, only: %i[edit update destroy]

  def index
    @categories = Category.includes(:template).ordered
    @templates = Template.includes(:category).ordered_by_category
  end

  def new
    category_id = params[:category_id].presence
    existing_template = category_id ? Template.find_by(category_id: category_id) : nil

    if existing_template
      @template = existing_template
    else
      @template = Template.new(category_id: category_id)
    end

    load_categories
  end

  def edit
    load_categories
  end

  def create
    # Check if category already has a template; if so, update it instead of failing validation
    target_category_id = template_params[:category_id]
    new_cat_name = template_params[:new_category_name].to_s.strip

    if new_cat_name.present?
      cat = Category.find_or_create_by!(name: new_cat_name)
      target_category_id = cat.id
    end

    existing_template = Template.find_by(category_id: target_category_id)

    if existing_template
      if existing_template.update(body: template_params[:body])
        redirect_to templates_path, notice: "Template for #{existing_template.category.name} updated."
      else
        @template = existing_template
        load_categories
        render :new, status: :unprocessable_entity
      end
    else
      @template = Template.new(template_params)
      @template.category_id = target_category_id if target_category_id.present?

      if @template.save
        redirect_to templates_path, notice: "Template for #{@template.category.name} created."
      else
        load_categories
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    if @template.update(template_params)
      redirect_to templates_path, notice: "Template for #{@template.category.name} updated."
    else
      load_categories
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    category_name = @template.category.name
    @template.destroy
    redirect_to templates_path, notice: "Template for #{category_name} removed."
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def load_categories
    @categories = Category.ordered
    @templates_map = Template.all.pluck(:category_id, :body).to_h
  end

  def template_params
    params.require(:template).permit(:category_id, :body, :new_category_name)
  end
end
