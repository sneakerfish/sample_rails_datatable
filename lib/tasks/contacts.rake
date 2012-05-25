namespace :contacts do
  desc "Add 100 random contacts to the database using Faker"
  task :add_random => :environment do
    100.times do |i|
      c = Contact.new
      c.first_name = Faker::Name.first_name
      c.last_name = Faker::Name.last_name
      c.phone = Faker::PhoneNumber.phone_number
      if rand > 0.6                             # About 40% will be free email addresses
        c.email = Faker::Internet.free_email(c.name)
      else
        c.email = Faker::Internet.email(c.name)
      end
      c.company = Faker::Company.name
      c.save
    end
  end  
end  
