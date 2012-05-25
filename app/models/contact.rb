class Contact < ActiveRecord::Base
  def name
    (first_name + " " + last_name).strip
  end
end
