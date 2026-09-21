require "test_helper"

# Exercises the JSON endpoint that DataTables calls in server-side mode.
class ContactsDatatableTest < ActionDispatch::IntegrationTest
  def fetch(**params)
    get contacts_url(format: :json), params: { draw: 1, start: 0, length: 10, **params }
    assert_response :success
    response.parsed_body
  end

  def last_names(json) = json["data"].map { |row| row["last_name"] }

  test "index page renders the table shell" do
    get root_url
    assert_response :success
    assert_select "table#contacts[data-source=?]", contacts_path(format: :json)
    assert_select "table#contacts th", 5
  end

  test "returns counts, echoes draw and includes row metadata" do
    json = fetch(draw: 7)
    assert_equal 7, json["draw"]
    assert_equal 3, json["recordsTotal"]
    assert_equal 3, json["recordsFiltered"]

    row = json["data"].find { |r| r["last_name"] == "Lovelace" }
    ada = contacts(:ada)
    assert_equal "contact_#{ada.id}", row["DT_RowId"]
    assert_equal edit_contact_path(ada), row["edit_path"]
    assert_equal "ada@example.com", row["email"]
  end

  test "sorts by the requested column and direction" do
    asc = fetch(order: { "0" => { column: 1, dir: "asc" } })
    assert_equal %w[Hopper Lovelace Turing], last_names(asc)

    desc = fetch(order: { "0" => { column: 1, dir: "desc" } })
    assert_equal %w[Turing Lovelace Hopper], last_names(desc)
  end

  test "ignores unknown sort columns and directions" do
    json = fetch(order: { "0" => { column: 99, dir: "; DROP TABLE contacts" } })
    assert_equal 3, json["data"].size
  end

  test "searches first name, last name and company" do
    json = fetch(search: { value: "bletchley" })
    assert_equal 1, json["recordsFiltered"]
    assert_equal 3, json["recordsTotal"]
    assert_equal %w[Turing], last_names(json)
  end

  test "treats LIKE wildcards in the search term literally" do
    assert_equal 0, fetch(search: { value: "%" })["recordsFiltered"]
  end

  test "paginates with start and length" do
    page = fetch(start: 1, length: 1, order: { "0" => { column: 1, dir: "asc" } })
    assert_equal %w[Lovelace], last_names(page)
    assert_equal 3, page["recordsFiltered"]
  end
end
