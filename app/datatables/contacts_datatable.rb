# Answers the AJAX requests that DataTables makes in "server-side processing"
# mode. DataTables sends the current page, sort order and search term as query
# parameters; we run the matching query and reply with one page of rows.
#
# Request/response format: https://datatables.net/manual/server-side
class ContactsDatatable
  # Column order must match the <th> order in app/views/contacts/index.html.erb.
  COLUMNS = %w[first_name last_name email phone company].freeze
  SEARCHABLE_COLUMNS = %w[first_name last_name company].freeze
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100

  delegate :edit_contact_path, to: :@view

  def initialize(view)
    @view = view
    # Only the parameters we use. DataTables sends order[0][column]=1&order[0][dir]=desc
    # (plus order[1]... when shift-clicking several headers), which permits as a list.
    @params = view.params.permit(:draw, :start, :length, search: [ :value ], order: [ :column, :dir ])
  end

  def as_json(_options = {})
    {
      draw: @params[:draw].to_i,        # echoed back so DataTables can ignore stale replies
      recordsTotal: Contact.count,      # rows before searching
      recordsFiltered: filtered.count,  # rows after searching
      data: rows
    }
  end

  private

  def rows
    filtered.order(ordering).offset(offset).limit(per_page).map do |contact|
      {
        DT_RowId: "contact_#{contact.id}",     # DataTables uses this as the <tr id="...">
        edit_path: edit_contact_path(contact), # not a column; read by the row click handler
        **contact.slice(*COLUMNS).symbolize_keys
      }
    end
  end

  def filtered
    @filtered ||= begin
      term = @params.dig(:search, :value).to_s.strip
      if term.present?
        pattern = "%#{Contact.sanitize_sql_like(term)}%"
        conditions = SEARCHABLE_COLUMNS.map { |column| Contact.arel_table[column].matches(pattern) }
        Contact.where(conditions.reduce(:or))
      else
        Contact.all
      end
    end
  end

  # Turns the requested sort into e.g. { "last_name" => :desc, "first_name" => :asc }.
  # Only known columns and directions get through, so user input never reaches the SQL.
  def ordering
    order_specs = @params.fetch(:order, {})
    order_specs = order_specs.values if order_specs.is_a?(ActionController::Parameters)

    order_specs.each_with_object({}) do |spec, order|
      index = Integer(spec[:column], exception: false)
      column = COLUMNS[index] if index&.between?(0, COLUMNS.size - 1)
      order[column] = spec[:dir] == "desc" ? :desc : :asc if column
    end.presence || { id: :asc }
  end

  def offset
    [ @params[:start].to_i, 0 ].max
  end

  def per_page
    length = @params[:length].to_i
    length.positive? ? [ length, MAX_PER_PAGE ].min : DEFAULT_PER_PAGE
  end
end
