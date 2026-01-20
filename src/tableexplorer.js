// Initialize table with data and columns passed from Julia
function initializeTable(tableData, columns) {
    // Custom sorter that handles missing/null values
    const customSorter = function(a, b, aRow, bRow, column, dir, sorterParams) {
        // Handle null/undefined/missing values - sort them to the bottom
        const aVal = a === null || a === undefined || a === "" ? null : a;
        const bVal = b === null || b === undefined || b === "" ? null : b;

        if (aVal === null && bVal === null) return 0;
        if (aVal === null) return 1;  // a goes to bottom
        if (bVal === null) return -1; // b goes to bottom

        // Normal comparison for non-null values
        if (typeof aVal === 'string' && typeof bVal === 'string') {
            return aVal.localeCompare(bVal);
        }

        if (aVal < bVal) return -1;
        if (aVal > bVal) return 1;
        return 0;
    };

    // Apply custom sorter to all columns
    columns.forEach(col => {
        col.sorter = customSorter;
    });

    // Initialize Tabulator
    const table = new Tabulator("#table", {
        data: tableData,
        columns: columns,
        layout: "fitData",
        height: "100%",
        movableColumns: true,
        resizableColumns: true,
        initialSort: [
            { column: columns[0].field, dir: "asc" }
        ]
    });

    return table;
}

// Control functions
function clearFilters() {
    // Clear all filters and header filter inputs
    window.tabulatorTable.clearFilter(true);
    // Manually clear all header filter input fields
    document.querySelectorAll('.tabulator-header-filter input').forEach(input => {
        input.value = '';
    });
    console.log("All filters cleared");
}

function exportCSV() {
    window.tabulatorTable.download("csv", "dataframe_export.csv");
}

function exportJSON() {
    window.tabulatorTable.download("json", "dataframe_export.json");
}

// Column toggle functionality
function toggleColumnMenu() {
    const menu = document.getElementById('columnMenu');
    menu.classList.toggle('show');
}

function populateColumnMenu(columns) {
    const menu = document.getElementById('columnMenu');
    menu.innerHTML = '';

    columns.forEach(col => {
        const item = document.createElement('div');
        item.className = 'column-menu-item';

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = col.visible !== false;
        checkbox.id = 'col-' + col.field;

        const label = document.createElement('label');
        label.htmlFor = 'col-' + col.field;
        label.textContent = col.title;
        label.style.cursor = 'pointer';

        checkbox.addEventListener('change', function() {
            if (this.checked) {
                window.tabulatorTable.showColumn(col.field);
            } else {
                window.tabulatorTable.hideColumn(col.field);
            }
        });

        item.appendChild(checkbox);
        item.appendChild(label);
        menu.appendChild(item);
    });
}

// Close menu when clicking outside
document.addEventListener('click', function(event) {
    const columnToggle = document.querySelector('.column-toggle');
    const menu = document.getElementById('columnMenu');
    if (columnToggle && menu && !columnToggle.contains(event.target)) {
        menu.classList.remove('show');
    }
});

// Update active row count and log when filters are applied
function setupFilterLogging(table) {
    table.on("dataFiltered", function(filters, rows){
        // Update the active row count display
        const activeRowsSpan = document.getElementById('activeRows');
        if (activeRowsSpan) {
            activeRowsSpan.textContent = rows.length;
        }
        console.log("Active filters:", filters.length, "| Visible rows:", rows.length);
    });
}
