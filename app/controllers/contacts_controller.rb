class ContactsController < ApplicationController
  before_action :set_contact, only: %i[edit update destroy]

  def index
    @query = params[:q].to_s.strip
    @contacts = Contact.search(@query).includes(lead: :category).order(name: :asc)
  end

  def new
    @contact = Contact.new
  end

  def edit
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to contacts_path, notice: "Contact #{@contact.name} was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to contacts_path, notice: "Contact #{@contact.name} was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @contact.name
    @contact.destroy
    redirect_to contacts_path, notice: "Contact #{name} was successfully deleted."
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :company, :role, :linkedin_url, :notes)
  end
end
