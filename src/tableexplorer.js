// Custom filter functions for numeric type filtering
function numericTypeFilter(headerValue, rowValue, rowData, filterParams) {
    // headerValue is an array of selected types (e.g., ["numerical", "NaN"])
    if (!headerValue || headerValue.length === 0) return true;

    // Categorize the row value
    let valueType;
    if (rowValue === null || rowValue === undefined || rowValue === '') {
        valueType = "(null)";
    } else if (rowValue === "NaN") {
        valueType = "NaN";
    } else if (rowValue === "Infinity") {
        valueType = "Infinity";
    } else if (rowValue === "-Infinity") {
        valueType = "-Infinity";
    } else if (typeof rowValue === 'number') {
        valueType = "numerical";
    } else {
        valueType = "numerical";  // Fallback
    }

    return headerValue.includes(valueType);
}

function numericTypeSingleFilter(headerValue, rowValue, rowData, filterParams) {
    // headerValue is a single selected type (e.g., "numerical")
    if (!headerValue) return true;

    // Categorize the row value
    let valueType;
    if (rowValue === null || rowValue === undefined || rowValue === '') {
        valueType = "(null)";
    } else if (rowValue === "NaN") {
        valueType = "NaN";
    } else if (rowValue === "Infinity") {
        valueType = "Infinity";
    } else if (rowValue === "-Infinity") {
        valueType = "-Infinity";
    } else if (typeof rowValue === 'number') {
        valueType = "numerical";
    } else {
        valueType = "numerical";  // Fallback
    }

    return valueType === headerValue;
}

// Initialize table with data and columns passed from Julia
function initializeTable(tableData, columns) {
    // Custom sorter that handles missing/null values and special numeric strings
    const customSorter = function(a, b, aRow, bRow, column, dir, sorterParams) {
        // Treat null/undefined/empty/NaN/Inf as null-like for sorting (sort to bottom)
        const isNullLike = (val) => {
            return val === null || val === undefined || val === "" ||
                   val === "NaN" || val === "Infinity" || val === "-Infinity";
        };

        const aIsNull = isNullLike(a);
        const bIsNull = isNullLike(b);

        if (aIsNull && bIsNull) return 0;  // Both null-like, equal
        if (aIsNull) return 1;  // a goes to bottom
        if (bIsNull) return -1; // b goes to bottom

        // Normal comparison for non-null values
        if (typeof a === 'string' && typeof b === 'string') {
            return a.localeCompare(b);
        }

        if (a < b) return -1;
        if (a > b) return 1;
        return 0;
    };

    // Apply custom sorter to all columns and register custom filter functions
    columns.forEach(col => {
        col.sorter = customSorter;

        // Register custom filter functions for numeric type filtering
        if (col.headerFilterFunc === "numericTypeFilter") {
            col.headerFilterFunc = numericTypeFilter;
        } else if (col.headerFilterFunc === "numericTypeSingleFilter") {
            col.headerFilterFunc = numericTypeSingleFilter;
        }
    });

    // Initialize Tabulator
    const table = new Tabulator("#table", {
        data: tableData,
        columns: columns,
        layout: "fitData",
        height: "100%",
        movableColumns: true,
        resizableColumns: true
    });

    // Update sort arrows for heatmap columns when sorting changes
    table.on("dataSorted", function(sorters, rows){
        // Reset all arrows to neutral circle
        document.querySelectorAll('.sort-arrow').forEach(arrow => {
            arrow.textContent = "○";
        });

        // Update arrow for sorted column(s)
        if (sorters.length > 0) {
            sorters.forEach(sorter => {
                const field = sorter.field;
                const dir = sorter.dir;
                const arrow = dir === "asc" ? "▲" : "▼";

                // Find the column header and update its arrow
                const columns = table.getColumns();
                columns.forEach(col => {
                    if (col.getField() === field) {
                        const headerElement = col.getElement();
                        const arrowElement = headerElement.querySelector('.sort-arrow');
                        if (arrowElement) {
                            arrowElement.textContent = arrow;
                        }
                    }
                });
            });
        }
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
