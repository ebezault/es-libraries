<style>


.container {
    width: 100%;
    padding: 0.3rem;
    box-sizing: border-box;
}

h1 {
    color: #2c3e50;
    margin-bottom: 20px;
    border-bottom: 3px solid #3498db;
    padding-bottom: 10px;
}

.error {
    background-color: #fee;
    color: #c33;
    padding: 15px;
    border-radius: 5px;
    margin: 10px 0;
    border-left: 4px solid #c33;
}

.info {
    background-color: #e3f2fd;
    color: #1976d2;
    padding: 15px;
    border-radius: 5px;
    margin: 10px 0;
    border-left: 4px solid #1976d2;
}

.loading {
    text-align: center;
    padding: 20px;
    color: #666;
}

.tables-section, .content-section {
    background: white;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

 .tables-list {
     display: flex;
     flex-wrap: wrap;
     flex-direction: row;
     gap: 0.5rem;
     margin-top: 15px;
     width: 80%;
 }

.table-item {
    padding: .3rem .6rem;
    background: #f8f9fa;
    border: 2px solid #e9ecef;
    border-radius: 5px;
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
    white-space: nowrap;
    flex: none;
    width: auto;
}

.table-item:hover {
    background: #e9ecef;
    border-color: #3498db;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.table-item.active {
    background: #3498db;
    color: white;
    border-color: #2980b9;
}

.tabs-container {
    margin-top: 20px;
}

.tabs-header {
    display: flex;
    border-bottom: 2px solid #ddd;
    margin-bottom: 20px;
}

.tab-button {
    padding: 12px 24px;
    background: transparent;
    border: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    font-size: 16px;
    font-weight: 500;
    color: #666;
    transition: all 0.2s;
    position: relative;
    top: 2px;
}

.tab-button:hover {
    color: #3498db;
    background: #f8f9fa;
}

.tab-button.active {
    color: #3498db;
    border-bottom-color: #3498db;
    font-weight: 600;
}

.tab-content {
    padding: 15px;
    background: #f8f9fa;
    border-radius: 5px;
    min-height: 200px;
}

.schema-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
}

.schema-table th,
.schema-table td {
    padding: 10px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

.schema-table th {
    background: #3498db;
    color: white;
    font-weight: 600;
}

.schema-table tr:hover {
    background: #f5f5f5;
}

.data-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    overflow-x: auto;
    display: block;
}

.data-table table {
    width: 100%;
    min-width: 600px;
}

.data-table th,
.data-table td {
    padding: 10px;
    text-align: left;
    border-bottom: 1px solid #ddd;
    word-break: break-word;
}

.data-table th {
    background: #2c3e50;
    color: white;
    position: sticky;
    top: 0;
    font-weight: 600;
}

.data-table tr:hover {
    background: #f5f5f5;
}

.data-table tr.data-row {
    cursor: pointer;
}

.data-table tr.data-row:hover {
    background: #e3f2fd;
}

.row-detail-modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
    overflow: auto;
}

.row-detail-content {
    background-color: white;
    margin: 20px auto;
    padding: 12px;
    border-radius: 8px;
    max-width: 900px;
    width: 90%;
    max-height: 85vh;
    overflow-y: auto;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.row-detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 2px solid #ddd;
}

.row-detail-header h3 {
    margin: 0;
    color: #2c3e50;
    font-size: 18px;
}

.close-detail {
    background: #e74c3c;
    color: white;
    border: none;
    padding: 3px 6px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
}

.close-detail:hover {
    background: #c0392b;
}

.row-detail-field {
    margin-bottom: 3px;
    padding: 2px 4px;
    background: #f8f9fa;
    border-radius: 4px;
    border-left: 3px solid #3498db;
}

.row-detail-field-label {
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 4px;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.row-detail-field-value {
    color: #333;
    word-break: break-all;
    white-space: pre-wrap;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    line-height: 1.4;
}

.row-detail-field-value.json {
    background: #2c3e50;
    color: #ecf0f1;
    padding: 8px;
    border-radius: 3px;
    overflow-x: auto;
}

.format-json-btn {
    background: #3498db;
    color: white;
    border: none;
    padding: 4px 8px;
    border-radius: 3px;
    cursor: pointer;
    font-size: 11px;
    font-weight: 500;
    margin-top: 4px;
    transition: background 0.2s;
}

.format-json-btn:hover {
    background: #2980b9;
}

.pagination {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 20px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 5px;
}

.pagination button {
    padding: 10px 20px;
    background: #3498db;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 14px;
    transition: background 0.2s;
}

.pagination button:hover:not(:disabled) {
    background: #2980b9;
}

.pagination button:disabled {
    background: #ccc;
    cursor: not-allowed;
}

.pagination-info {
    color: #666;
    font-size: 14px;
}

.query-section {
    margin-top: 20px;
    padding: 15px;
    background: #fff3cd;
    border-radius: 5px;
    border-left: 4px solid #ffc107;
}

.query-section textarea {
    width: 100%;
    min-height: 100px;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-family: monospace;
    font-size: 14px;
    margin-top: 10px;
}

.query-section button {
    margin-top: 10px;
    padding: 10px 20px;
    background: #ffc107;
    color: #333;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-weight: 600;
}

.query-section button:hover {
    background: #ffb300;
}
</style>

<div class="container">
    <div class="tables-section">
        <h2>Tables</h2>
        <div id="loading-tables" class="loading">Loading tables...</div>
        <div id="error-tables" class="error" style="display: none;"></div>
        <div id="tables-list" class="tables-list" style="display: none;"></div>
    </div>
    
    <div id="content-section" class="content-section" style="display: none;">
        <h2 id="table-title">Table: <span id="selected-table"></span></h2>
        
        <div class="tabs-container">
            <div class="tabs-header">
                <button class="tab-button active" id="tab-schema-btn" onclick="switchTab('schema')">Schema</button>
                <button class="tab-button" id="tab-data-btn" onclick="switchTab('data')">Data</button>
            </div>
            
            <div class="tab-content" id="tab-schema-content">
                <div id="loading-schema" class="loading">Loading schema...</div>
                <div id="schema-content" style="display: none;"></div>
            </div>
            
            <div class="tab-content" id="tab-data-content" style="display: none;">
                <div id="loading-data" class="loading">Loading data...</div>
                <div id="error-data" class="error" style="display: none;"></div>
                <div id="data-content" class="data-table" style="display: none;"></div>
                <div id="pagination" class="pagination" style="display: none;">
                    <button id="btn-prev" onclick="loadPreviousPage()">Previous</button>
                    <div class="pagination-info">
                        <span id="page-info"></span>
                    </div>
                    <button id="btn-next" onclick="loadNextPage()">Next</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Row Detail Modal -->
<div id="row-detail-modal" class="row-detail-modal" onclick="closeRowDetail(event)">
    <div class="row-detail-content" onclick="event.stopPropagation()">
        <div class="row-detail-header">
            <h3>Row Details</h3>
            <button class="close-detail" onclick="closeRowDetail()">Close</button>
        </div>
        <div id="row-detail-body"></div>
    </div>
</div>

<script>
const API_BASE = '{{api_path}}';
let currentTable = null;
let currentOffset = 0;
let currentLimit = 50;
let currentRows = [];
let currentTab = 'schema'; // Remember the selected tab

// Load tables on page load
window.addEventListener('DOMContentLoaded', function() {
    loadTables();
});

function loadTables() {
    fetch(API_BASE + '/tables', {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showError('tables', data.message || 'Failed to load tables');
                return;
            }
            
            const tables = data.rows || [];
            const listEl = document.getElementById('tables-list');
            listEl.innerHTML = '';
            
            tables.forEach(table => {
                const item = document.createElement('div');
                item.className = 'table-item';
                item.textContent = table;
                item.onclick = () => selectTable(table);
                listEl.appendChild(item);
            });
            
            document.getElementById('loading-tables').style.display = 'none';
            document.getElementById('tables-list').style.display = 'flex';
        })
        .catch(error => {
            showError('tables', 'Failed to load tables: ' + error.message);
        });
}

function selectTable(tableName) {
    // Update active state
    document.querySelectorAll('.table-item').forEach(item => {
        item.classList.remove('active');
        if (item.textContent === tableName) {
            item.classList.add('active');
        }
    });
    
    currentTable = tableName;
    currentOffset = 0;
    
    document.getElementById('selected-table').textContent = tableName;
    document.getElementById('content-section').style.display = 'block';
    
    // Clear old content
    document.getElementById('schema-content').innerHTML = '';
    document.getElementById('data-content').innerHTML = '';
    document.getElementById('error-data').style.display = 'none';
    currentRows = [];
    
    // Switch to the previously selected tab (or schema by default)
    switchTab(currentTab);
    
    // Load content based on the selected tab
    if (currentTab === 'schema') {
        loadSchema(tableName);
    } else if (currentTab === 'data') {
        loadTableData(tableName, 0);
    }
}

function switchTab(tabName) {
    // Remember the selected tab
    currentTab = tabName;
    
    // Update tab buttons
    document.getElementById('tab-schema-btn').classList.remove('active');
    document.getElementById('tab-data-btn').classList.remove('active');
    
    // Hide all tab contents
    document.getElementById('tab-schema-content').style.display = 'none';
    document.getElementById('tab-data-content').style.display = 'none';
    
    // Show selected tab and activate button
    if (tabName === 'schema') {
        document.getElementById('tab-schema-btn').classList.add('active');
        document.getElementById('tab-schema-content').style.display = 'block';
        // Load schema if not already loaded
        if (currentTable) {
            const schemaContent = document.getElementById('schema-content');
            if (schemaContent.innerHTML === '') {
                loadSchema(currentTable);
            }
        }
    } else if (tabName === 'data') {
        document.getElementById('tab-data-btn').classList.add('active');
        document.getElementById('tab-data-content').style.display = 'block';
        // Load data if not already loaded
        if (currentTable) {
            const dataContent = document.getElementById('data-content');
            if (dataContent.innerHTML === '') {
                loadTableData(currentTable, 0);
            }
        }
    }
}

function loadSchema(tableName) {
    const loadingEl = document.getElementById('loading-schema');
    const contentEl = document.getElementById('schema-content');
    
    loadingEl.style.display = 'block';
    contentEl.style.display = 'none';
    
    fetch(API_BASE + '/tables/' + encodeURIComponent(tableName) + '/schema', {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                loadingEl.style.display = 'none';
                return;
            }
            
            const columns = data.columns || [];
            let html = '<table class="schema-table"><thead><tr><th>Column</th><th>Type</th><th>Nullable</th></tr></thead><tbody>';
            
            columns.forEach(col => {
                html += '<tr>';
                html += '<td>' + escapeHtml(col.name) + '</td>';
                html += '<td>' + escapeHtml(col.type) + '</td>';
                html += '<td>' + (col.nullable ? 'Yes' : 'No') + '</td>';
                html += '</tr>';
            });
            
            html += '</tbody></table>';
            
            contentEl.innerHTML = html;
            loadingEl.style.display = 'none';
            contentEl.style.display = 'block';
        })
        .catch(error => {
            loadingEl.style.display = 'none';
        });
}

function loadTableData(tableName, offset) {
    const loadingEl = document.getElementById('loading-data');
    const contentEl = document.getElementById('data-content');
    const paginationEl = document.getElementById('pagination');
    const errorEl = document.getElementById('error-data');
    
    loadingEl.style.display = 'block';
    contentEl.style.display = 'none';
    paginationEl.style.display = 'none';
    errorEl.style.display = 'none';
    
    const url = API_BASE + '/tables/' + encodeURIComponent(tableName) + '/items?offset=' + offset + '&count=' + currentLimit;
    
    fetch(url, {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                showError('data', data.message || 'Failed to load data');
                loadingEl.style.display = 'none';
                return;
            }
            
            const rows = data.rows || [];
            if (rows.length === 0) {
                contentEl.innerHTML = '<p>No data found.</p>';
                loadingEl.style.display = 'none';
                contentEl.style.display = 'block';
                return;
            }
            
            // Get column names from first row
            const columns = Object.keys(rows[0]);
            
            let html = '<table><thead><tr>';
            columns.forEach(col => {
                html += '<th>' + escapeHtml(col) + '</th>';
            });
            html += '</tr></thead><tbody>';
            
            // Store rows for detail view
            currentRows = rows;
            
            rows.forEach((row, rowIndex) => {
                html += '<tr class="data-row" onclick="showRowDetail(' + rowIndex + ')">';
                columns.forEach(col => {
                    const value = row[col];
                    html += '<td>' + formatValue(value) + '</td>';
                });
                html += '</tr>';
            });
            
            html += '</tbody></table>';
            
            contentEl.innerHTML = html;
            loadingEl.style.display = 'none';
            contentEl.style.display = 'block';
            
            // Update pagination
            currentOffset = offset;
            const hasMore = data.has_more || false;
            const count = data.count || 0;
            
            document.getElementById('page-info').textContent = 
                'Showing ' + (offset + 1) + '-' + (offset + count) + ' of items';
            
            document.getElementById('btn-prev').disabled = offset === 0;
            document.getElementById('btn-next').disabled = !hasMore;
            
            paginationEl.style.display = 'flex';
        })
        .catch(error => {
            showError('data', 'Failed to load data: ' + error.message);
            loadingEl.style.display = 'none';
        });
}

function loadNextPage() {
    if (currentTable) {
        loadTableData(currentTable, currentOffset + currentLimit);
    }
}

function loadPreviousPage() {
    if (currentTable && currentOffset > 0) {
        const newOffset = Math.max(0, currentOffset - currentLimit);
        loadTableData(currentTable, newOffset);
    }
}

function showError(section, message) {
    const errorEl = document.getElementById('error-' + section);
    if (errorEl) {
        errorEl.textContent = message;
        errorEl.style.display = 'block';
    }
}

function escapeHtml(text) {
    if (text === null || text === undefined) {
        return '';
    }
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatValue(value) {
    if (value === null || value === undefined) {
        return '<em>null</em>';
    }
    if (typeof value === 'object') {
        return '<pre>' + escapeHtml(JSON.stringify(value, null, 2)) + '</pre>';
    }
    const str = String(value);
    if (str.length > 100) {
        return escapeHtml(str.substring(0, 100)) + '...';
    }
    return escapeHtml(str);
}

let currentDetailRowData = null;

function showRowDetail(rowIndex) {
    if (!currentRows || rowIndex < 0 || rowIndex >= currentRows.length) {
        return;
    }
    
    const rowData = currentRows[rowIndex];
    currentDetailRowData = rowData;
    const modal = document.getElementById('row-detail-modal');
    const body = document.getElementById('row-detail-body');
    
    let html = '';
    let fieldIndex = 0;
    for (const key in rowData) {
        if (rowData.hasOwnProperty(key)) {
            const value = rowData[key];
            const isJson = isJsonValue(value);
            const escapedKey = escapeHtml(key).replace(/'/g, "\\'");
            html += '<div class="row-detail-field" data-field-key="' + escapeHtml(key) + '">';
            html += '<div class="row-detail-field-label">' + escapeHtml(key) + '</div>';
            html += '<div class="row-detail-field-value' + (isJson ? ' json' : '') + '" id="field-value-' + fieldIndex + '">';
            html += formatValueForDetail(value, false);
            html += '</div>';
            if (isJson) {
                html += '<button class="format-json-btn" onclick="formatJsonField(' + fieldIndex + ', \'' + escapedKey + '\')">Format JSON</button>';
            }
            html += '</div>';
            fieldIndex++;
        }
    }
    
    body.innerHTML = html;
    modal.style.display = 'block';
}

function closeRowDetail(event) {
    if (event && event.target !== event.currentTarget && event.target.className !== 'close-detail') {
        return;
    }
    document.getElementById('row-detail-modal').style.display = 'none';
}

function formatValueForDetail(value, formatJson) {
    formatJson = formatJson !== undefined ? formatJson : false;
    if (value === null || value === undefined) {
        return '<em>null</em>';
    }
    if (typeof value === 'object') {
        try {
            if (formatJson) {
                return escapeHtml(JSON.stringify(value, null, 2));
            } else {
                return escapeHtml(JSON.stringify(value));
            }
        } catch (e) {
            return escapeHtml(String(value));
        }
    }
    if (typeof value === 'string') {
        // Try to parse if it's a JSON string
        try {
            const parsed = JSON.parse(value);
            if (formatJson) {
                return escapeHtml(JSON.stringify(parsed, null, 2));
            } else {
                return escapeHtml(value);
            }
        } catch (e) {
            // Not valid JSON, return as-is
            return escapeHtml(value);
        }
    }
    return escapeHtml(String(value));
}

function formatJsonField(fieldIndex, fieldKey) {
    if (!currentDetailRowData || !currentDetailRowData.hasOwnProperty(fieldKey)) {
        return;
    }
    
    const value = currentDetailRowData[fieldKey];
    const fieldEl = document.getElementById('field-value-' + fieldIndex);
    if (fieldEl) {
        const formatted = formatValueForDetail(value, true);
        fieldEl.innerHTML = formatted;
        // Hide the button after formatting
        const field = fieldEl.closest('.row-detail-field');
        const btn = field.querySelector('.format-json-btn');
        if (btn) {
            btn.style.display = 'none';
        }
    }
}

function isJsonValue(value) {
    if (value === null || value === undefined) {
        return false;
    }
    if (typeof value === 'object') {
        return true;
    }
    if (typeof value === 'string') {
        try {
            JSON.parse(value);
            return value.trim().startsWith('{') || value.trim().startsWith('[');
        } catch (e) {
            return false;
        }
    }
    return false;
}
</script>
