// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import DataTable from "datatables.net"

const element = document.querySelector("#contacts")

if (element) {
  // serverSide: DataTables asks the server for each page instead of loading every row up front.
  // See app/datatables/contacts_datatable.rb for the Rails side.
  const table = new DataTable(element, {
    serverSide: true,
    processing: true,
    ajax: element.dataset.source,
    // Column keys match the JSON the server returns. render.text() HTML-escapes values.
    columns: [ "first_name", "last_name", "email", "phone", "company" ].map((data) => (
      { data, render: DataTable.render.text() }
    ))
  })

  // Clicking a row opens that contact's edit page. table.row(tr).data() is the row's JSON
  // from the server, which includes an edit_path alongside the column values.
  element.querySelector("tbody").addEventListener("click", (event) => {
    const tr = event.target.closest("tr")
    const contact = tr && table.row(tr).data()
    if (contact?.edit_path) window.location = contact.edit_path
  })
}
