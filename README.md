# Sample Rails DataTable

A small Rails app that shows how to drive a [DataTables](https://datatables.net/) table from Rails
with **server-side processing**: the browser only ever holds one page of rows, and Rails handles
sorting, searching and paging with ordinary Active Record queries.

It is a single `Contact` model (first name, last name, email, phone, company) with a standard
scaffold, plus:

- **Sorting**: click a column header; shift-click to sort by several columns.
- **Searching**: the search box filters on first name, last name and company.
- **Paging**: page through results and choose 10, 25, 50 or 100 rows per page.
- **Row click**: clicking a row opens that contact's edit page.

Built with Rails 8.1, Ruby 3.4, SQLite, Propshaft and import maps (no Node.js or bundler needed).
DataTables 3 doesn't need jQuery, so the page loads no jQuery at all.

## How it works

| File | What it does |
| --- | --- |
| `app/views/contacts/index.html.erb` | Renders an empty `<table>` whose `data-source` attribute points at `/contacts.json`. |
| `app/javascript/application.js` | Turns that table into a DataTable with `serverSide: true`, and handles row clicks. |
| `app/controllers/contacts_controller.rb` | `index` renders the page for HTML requests and `ContactsDatatable` for JSON requests. |
| `app/datatables/contacts_datatable.rb` | Reads DataTables' request parameters (`start`, `length`, `search[value]`, `order[i][column]`, `order[i][dir]`), builds the query and returns the JSON DataTables expects. |
| `config/importmap.rb`, `vendor/javascript/datatables.net.js` | DataTables, pinned with `bin/importmap pin datatables.net --from jsdelivr`. |
| `vendor/assets/stylesheets/datatables.css` | DataTables' default stylesheet. |

The request/response format is described in the DataTables
[server-side processing manual](https://datatables.net/manual/server-side). The tests in
`test/controllers/contacts_datatable_test.rb` show example requests and responses.

## Running it

### With Docker (no local Ruby needed)

```sh
docker compose up
```

Then open <http://localhost:3000>. The first start installs gems and creates and seeds the
database, so give it a minute. Stop with `Ctrl-C`. To run other commands:

```sh
docker compose run --rm web bin/rails test
docker compose run --rm web bin/rails contacts:add_random COUNT=500
```

### With a local Ruby

You need Ruby 3.4 (see `.ruby-version`) and SQLite 3.

```sh
bin/setup   # installs gems, creates and seeds the database, then starts the server
```

or step by step:

```sh
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Then open <http://localhost:3000>.

## Sample data

`bin/rails db:seed` fills the table with 250 fake contacts from the [Faker](https://github.com/faker-ruby/faker)
gem (re-running it only tops the table back up to 250). To add more:

```sh
bin/rails contacts:add_random            # 100 more
bin/rails contacts:add_random COUNT=1000
```

## Tests and checks

```sh
bin/rails test          # model and controller tests, including the DataTables JSON endpoint
bin/bundler-audit       # known vulnerabilities in gems
bin/importmap audit     # known vulnerabilities in pinned JavaScript
bin/brakeman            # static security analysis
bin/ci                  # all of the above
```

The same checks run on GitHub Actions for every pull request (`.github/workflows/ci.yml`).

## History

This app was originally written in 2012 for Rails 3.2 with jQuery, jQuery UI, the
`jquery-datatables-rails` gem and Kaminari. In 2026 it was rebuilt on a fresh Rails 8.1 skeleton
with the same model, pages and behaviour, using DataTables 3 through import maps and plain
`offset`/`limit` for paging.
