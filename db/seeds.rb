# Loads demo data so the datatable has something to sort, search and page through.
# Run with `bin/rails db:seed` (bin/setup and db:prepare also run it on a fresh database).
# Safe to re-run: it only tops the table up to TARGET contacts.
# Need more? `bin/rails contacts:add_random COUNT=1000`.

TARGET = 250

(TARGET - Contact.count).times do
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

puts "#{Contact.count} contacts in the database."
