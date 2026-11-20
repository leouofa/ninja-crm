module Api
  module V1
    class BaseController < ActionController::API
      wrap_parameters false

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

      def openapi
        spec_path = Rails.root.join("public/api/v1/openapi.json")
        if File.exist?(spec_path)
          render file: spec_path, content_type: "application/json"
        else
          render json: { error: "OpenAPI specification not found" }, status: :not_found
        end
      end

      protected

      def paginate(scope)
        limit = [ params.fetch(:limit, 50).to_i, 100 ].min
        limit = 50 if limit <= 0
        offset = [ params.fetch(:offset, 0).to_i, 0 ].max

        total_count = scope.count
        response.headers["X-Total-Count"] = total_count.to_s
        response.headers["X-Limit"] = limit.to_s
        response.headers["X-Offset"] = offset.to_s

        scope.limit(limit).offset(offset)
      end

      def resource_params(root_key, permitted_keys)
        source = params.key?(root_key) ? params.require(root_key) : params
        source.permit(*permitted_keys)
      end

      def render_validation_errors(record)
        render json: {
          error: "Validation failed",
          errors: record.errors.full_messages
        }, status: :unprocessable_entity
      end

      private

      def not_found(exception)
        model_name = exception.model || "Resource"
        render json: { error: "#{model_name} not found" }, status: :not_found
      end

      def parameter_missing(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      def record_invalid(exception)
        render_validation_errors(exception.record)
      end
    end
  end
end
