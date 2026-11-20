class LeadsController < ApplicationController
  before_action :set_lead, only: %i[edit update destroy move]

  def index
    @categories = Category.ordered
    @selected_category_id = params[:category_id].presence
    @view = params[:view] == "archived" ? "archived" : "active"

    @active_count = Lead.active.count
    @archived_count = Lead.archived.count

    if @view == "archived"
      archived_scope = Lead.archived.includes(:contact, :category).order(updated_at: :desc)
      archived_scope = archived_scope.where(category_id: @selected_category_id) if @selected_category_id.present?
      @archived_leads = archived_scope
    else
      leads_scope = Lead.active.includes(:contact, :category).order(updated_at: :desc)
      leads_scope = leads_scope.where(category_id: @selected_category_id) if @selected_category_id.present?

      active_statuses = %w[backlog in_progress done]
      @leads_by_status = active_statuses.index_with do |st|
        leads_scope.select { |lead| lead.status == st }
      end
    end
  end

  def new
    @lead = Lead.new(
      contact_id: params[:contact_id],
      status: params[:status] || "backlog"
    )
    load_form_collections
  end

  def edit
    load_form_collections
  end

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      redirect_to leads_path, notice: "Lead for #{@lead.contact.name} was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lead.update(lead_params)
      redirect_to leads_path, notice: "Lead for #{@lead.contact.name} was successfully updated."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def move
    new_status = params[:status]

    if Lead.statuses.key?(new_status)
      @lead.update(status: new_status)
      notice_message = new_status == "archived" ? "Lead for #{@lead.contact.name} was archived." : "Lead status updated to #{@lead.status_label}."
      respond_to do |format|
        format.json { render json: { status: "success", lead: @lead } }
        format.html { redirect_back fallback_location: leads_path, notice: notice_message }
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Invalid status" }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: leads_path, alert: "Invalid status." }
      end
    end
  end

  def destroy
    contact_name = @lead.contact.name
    @lead.destroy
    redirect_back fallback_location: leads_path, notice: "Lead for #{contact_name} was removed."
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def load_form_collections
    @categories = Category.ordered
    @contacts = if @lead.persisted?
      Contact.where(id: [ @lead.contact_id ] + Contact.without_lead.pluck(:id)).order(:name)
    elsif @lead.contact_id.present?
      Contact.where(id: @lead.contact_id)
    else
      Contact.without_lead.order(:name)
    end
  end

  def lead_params
    params.require(:lead).permit(:contact_id, :category_id, :status, :notes, :new_category_name)
  end
end
