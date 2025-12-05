set style [ get element, call style ]
get build, call [ get document head ] [ get style ]
set [ get style ] textContent '
 table.code-column-2 tr:not(:first-of-type) td:nth-child(2),
 pre {
  font-family: monospace;
  font-size: 95%;
  white-space: pre-wrap;
 }
 table {
  width: 100%;
  border-collapse: collapse;
 }
 table tr:first-of-type {
  border-bottom: 1px solid;
 }
 td {
  padding: 10px;
  vertical-align: top;
  white-space: pre-wrap;
 }
 iframe {
  background-color: white;
  border: 2px solid #797979;
  box-sizing: border-box;
  width: 100%;
 }
'
