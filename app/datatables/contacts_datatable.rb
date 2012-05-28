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
        iTotalDisplayRecords: get_data  .count,
        aaData: format_data
      }
  end
  
  private
      
  def format_data
    get_data.order(order).page(page).per(per_page).map do |contact|
       { "0" =>  contact.first_name,
         "1" => contact.last_name,
         "2" => contact.email,
         "3" => contact.phone,
         "4" => contact.company,
         "DT_RowId" =>  contact.id } 
      end
  end
  
  def data_size
    get_data.size
  end
  
  def get_data
    @data ||= fetch_data
  end      
  
  def order
    o = []
    columns = %w[first_name last_name email phone company]
    (columns.size).times do |i|
      sortsym = "iSortCol_#{i}".to_sym
      dirsym = "sSortDir_#{i}".to_sym
      if params[sortsym].present?
        o << columns[params[sortsym].to_i] +
          if params[dirsym].present? and params[dirsym] == "desc"
            " desc"
          else
            ""
          end
      end
    end
    o.join(", ")
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