module Api
  module V1
    class CategoriesController < BaseController
      before_action :set_category, only: [ :show, :update, :destroy ]

      PERMITTED_PARAMS = [ :name ].freeze

      def index
        categories = Category.includes(:template)
        if params[:q].present?
          q = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
          categories = categories.where("name ILIKE :q", q: q)
        end

        categories = categories.order(name: :asc)
        paginated = paginate(categories)
        render json: paginated.map { |category| category_json(category) }
      end

      def show
        render json: category_json(@category)
      end

      def create
        @category = Category.new(category_params)
        if @category.save
          render json: category_json(@category), status: :created
        else
          render_validation_errors(@category)
        end
      end

      def update
        if @category.update(category_params)
          render json: category_json(@category)
        else
          render_validation_errors(@category)
        end
      end

      def destroy
        if @category.destroy
          head :no_content
        else
          render_validation_errors(@category)
        end
      end

      private

      def set_category
        @category = Category.includes(:template).find(params[:id])
      end

      def category_params
        resource_params(:category, PERMITTED_PARAMS)
      end

      def category_json(category)
        category.as_json.merge(
          "has_template" => category.template.present?,
          "template" => category.template ? {
            "id" => category.template.id,
            "body" => category.template.body,
            "created_at" => category.template.created_at,
            "updated_at" => category.template.updated_at
          } : nil
        )
      end
    end
  end
end
