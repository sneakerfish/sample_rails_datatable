class Contact < ApplicationRecord
  def name
    [ first_name, last_name ].compact_blank.join(" ")
  end
end
