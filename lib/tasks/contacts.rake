namespace :contacts do
  desc "Add random contacts using Faker (COUNT=100 by default)"
  task add_random: :environment do
    count = Integer(ENV.fetch("COUNT", 100))

    count.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      name = "#{first_name} #{last_name}"

      Contact.create!(
        first_name: first_name,
        last_name: last_name,
        phone: Faker::PhoneNumber.phone_number,
        email: Faker::Internet.email(name: name),
        company: Faker::Company.name
      )
    end

    puts "Added #{count} contacts (#{Contact.count} total)."
  end
end
