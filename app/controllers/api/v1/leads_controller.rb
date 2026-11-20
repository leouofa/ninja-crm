module Api
  module V1
    class LeadsController < BaseController
      before_action :set_lead, only: [ :show, :update, :destroy ]

      PERMITTED_PARAMS = [ :contact_id, :category_id, :status, :notes, :new_category_name ].freeze
      ALLOWED_SORT_COLUMNS = %w[ created_at updated_at status ].freeze

      def index
        leads = Lead.includes(:contact, :category)

        leads = leads.where(status: params[:status]) if params[:status].present?
        leads = leads.where(category_id: params[:category_id]) if params[:category_id].present?
        leads = leads.where(contact_id: params[:contact_id]) if params[:contact_id].present?

        if params[:q].present?
          q = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
          leads = leads.joins(:contact).where(
            "contacts.name ILIKE :q OR contacts.company ILIKE :q OR contacts.email ILIKE :q OR leads.notes ILIKE :q",
            q: q
          )
        end

        sort_column = ALLOWED_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "updated_at"
        sort_order = params[:order].to_s.downcase == "asc" ? :asc : :desc
        leads = leads.order(sort_column => sort_order)

        paginated = paginate(leads)
        render json: paginated.map { |lead| lead_json(lead) }
      end

      def show
        render json: lead_json(@lead)
      end

      def create
        @lead = Lead.new(lead_params)
        if @lead.save
          render json: lead_json(@lead), status: :created
        else
          render_validation_errors(@lead)
        end
      end

      def update
        if @lead.update(lead_params)
          render json: lead_json(@lead)
        else
          render_validation_errors(@lead)
        end
      end

      def destroy
        @lead.destroy
        head :no_content
      end

      private

      def set_lead
        @lead = Lead.includes(:contact, :category).find(params[:id])
      end

      def lead_params
        resource_params(:lead, PERMITTED_PARAMS)
      end

      def lead_json(lead)
        lead.as_json.merge(
          "status_label" => lead.status_label,
          "contact" => lead.contact&.as_json,
          "category" => lead.category&.as_json
        )
      end
    end
  end
end
