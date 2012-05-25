class ContactsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
    @data = nil
  end
  
  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Contact.count,
        iTotalDisplayRecords: Contact.count,
        aaData: format_data
      }
  end
  
  private
      
  def format_data
    get_data.page(page).per(per_page).map do |contact|
      [ contact.first_name,
        contact.last_name,
        contact.email,
        contact.phone,
        contact.company
        ]
      end
  end
  
  def data_size
    get_data.size
  end
  
  def get_data
    @data ||= fetch_data
  end
                        
  def fetch_data
    if params[:sSearch].present?
      contacts = Contact.where("first_name like :search or last_name like :search or company like :search", 
        search: "%#{params[:sSearch]}%")
    else
      contacts = Contact.where('')
    end
    contacts
  end
  
  def page
    params[:iDisplayStart].to_i / per_page + 1
  end 
                                              
  
  def per_page
    params[:iDisplayLength].to_i.zero? ? 10 : params[:iDisplayLength].to_i
  end
  
  
end