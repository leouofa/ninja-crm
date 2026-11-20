module Api
  module V1
    class ContactsController < BaseController
      before_action :set_contact, only: [ :show, :update, :destroy ]

      PERMITTED_PARAMS = [ :name, :email, :phone, :company, :role, :linkedin_url, :notes ].freeze
      ALLOWED_SORT_COLUMNS = %w[ name email company role created_at updated_at ].freeze

      def index
        contacts = Contact.includes(:lead)
        contacts = contacts.search(params[:q]) if params[:q].present?

        sort_column = ALLOWED_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
        sort_order = params[:order].to_s.downcase == "desc" ? :desc : :asc
        contacts = contacts.order(sort_column => sort_order)

        paginated = paginate(contacts)
        render json: paginated.map { |contact| contact_json(contact) }
      end

      def show
        render json: contact_json(@contact)
      end

      def create
        @contact = Contact.new(contact_params)
        if @contact.save
          render json: contact_json(@contact), status: :created
        else
          render_validation_errors(@contact)
        end
      end

      def update
        if @contact.update(contact_params)
          render json: contact_json(@contact)
        else
          render_validation_errors(@contact)
        end
      end

      def destroy
        @contact.destroy
        head :no_content
      end

      private

      def set_contact
        @contact = Contact.includes(:lead).find(params[:id])
      end

      def contact_params
        resource_params(:contact, PERMITTED_PARAMS)
      end

      def contact_json(contact)
        contact.as_json.merge(
          "has_lead" => contact.lead.present?,
          "lead" => contact.lead ? {
            "id" => contact.lead.id,
            "category_id" => contact.lead.category_id,
            "status" => contact.lead.status,
            "status_label" => contact.lead.status_label,
            "notes" => contact.lead.notes,
            "created_at" => contact.lead.created_at,
            "updated_at" => contact.lead.updated_at
          } : nil
        )
      end
    end
  end
end
