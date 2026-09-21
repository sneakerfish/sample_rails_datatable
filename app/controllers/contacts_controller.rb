class ContactsController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy ]

  # GET /contacts        - the page with the (empty) table
  # GET /contacts.json   - the rows DataTables fetches over AJAX
  def index
    respond_to do |format|
      format.html
      format.json { render json: ContactsDatatable.new(view_context) }
    end
  end

  # GET /contacts/1
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to @contact, notice: "Contact was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /contacts/1
  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "Contact was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /contacts/1
  def destroy
    @contact.destroy!
    redirect_to contacts_path, notice: "Contact was successfully destroyed.", status: :see_other
  end

  private
    def set_contact
      @contact = Contact.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def contact_params
      params.expect(contact: [ :first_name, :last_name, :email, :phone, :company ])
    end
end
