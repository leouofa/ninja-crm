module Api
  module V1
    class TemplatesController < BaseController
      before_action :set_template, only: [ :show, :update, :destroy ]

      PERMITTED_PARAMS = [ :category_id, :body, :new_category_name ].freeze

      def index
        templates = Template.includes(:category)
        templates = templates.where(category_id: params[:category_id]) if params[:category_id].present?
        templates = templates.order(created_at: :desc)

        paginated = paginate(templates)
        render json: paginated.map { |template| template_json(template) }
      end

      def show
        render json: template_json(@template)
      end

      def create
        @template = Template.new(template_params)
        if @template.save
          render json: template_json(@template), status: :created
        else
          render_validation_errors(@template)
        end
      end

      def update
        if @template.update(template_params)
          render json: template_json(@template)
        else
          render_validation_errors(@template)
        end
      end

      def destroy
        @template.destroy
        head :no_content
      end

      private

      def set_template
        @template = Template.includes(:category).find(params[:id])
      end

      def template_params
        resource_params(:template, PERMITTED_PARAMS)
      end

      def template_json(template)
        template.as_json.merge(
          "category" => template.category&.as_json
        )
      end
    end
  end
end
