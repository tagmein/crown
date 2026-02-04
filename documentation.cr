set document [ at document ]
set location [ at location ]

set [ get document ] title 'Crown Documentation'

set build [ load ./lib/build.cr, point ]
set element [ load ./lib/element.cr, point ]

do [ load ./lib/main-style.cr, point ]

set anchor [ load ./lib/anchor.cr, point ]
set code [ load ./lib/code.cr, point ]
set header [ load ./lib/header.cr, point ]
set paragraph [ load ./lib/paragraph.cr, point ]
set span [ load ./lib/span.cr, point ]
set table [ load ./lib/table.cr, point ]
set table-row [ load ./lib/table-row.cr, point ]

get header, call Crown

get header, call 'Current version: 2026-02-04' 4

get header, call 'License: Public domain' 4

get paragraph, call 'Crown is a metaprogramming syntax that can be implemented in any programming environment. You are currently viewing a document written in Crown for JavaScript.'

get paragraph, call 'The Crown engine runs code one command at a time, and maintains an \'implicit focus\' at all times. This means that the results of the last command are always available for the next command, and so on. A sample Crown program might look like:'

get code, call 'add 4 5, log The sum is [ current ] # prints \'The sum is 9\' to the console'

get header, call 'Getting Started' 2

get paragraph, call [
 template 'Download a copy of the Crown JavaScript Engine from <a href="%0/crown.js">%0/crown.js</a> and add the following code to an HTML file:' [ get location origin ]
]
get code, call '<!doctype html>
<html>

<head>
 <meta charset="utf-8" />
 <title>My Website</title>
 <script type="text/javascript" src="./crown.js"></script>
</head>

<body>
 <noscript>JavaScript is required</noscript>
 <script type="text/javascript">
  async function main() {
   await crown().run`
    set document [ at document ]
    set greeting [ get document createElement, call h1 ]
    get document body appendChild, call [ get greeting ]
    set [ get greeting ] textContent \'Hello, world\'
   `
   // or, if your Crown code is in a file:
   // await crown().runFile(\'./main.cr\')
  }
  main().catch(e => console.error(e))
 </script>
</body>

</html>
'

get paragraph, call 'If everything is set up properly, meaning the ./crown.js file is accessible, loading the HTML file in a browser will produce the following:'

set exampleFrame [ get element, call iframe ]
get exampleFrame setAttribute, call srcdoc '
 <!doctype html>
 <meta charset="UTF-8">
 <h1>Hello, world</h1>
'
get document body appendChild, call [
 get exampleFrame
]

get header, call 'Crown Syntax' 2

get paragraph, call 'Crown has only 10 syntax characters: <code>⏎,[]()*\'\\#</code>'

set syntaxTable [ get table, call ]

get syntaxTable classList add, call code-column-2

get table-row, call [ get syntaxTable ] [
 list [ Name, Symbol, Description ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'new line'
  '<line break>'
  'separates statements'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'comma'
  ','
  'separates statements, is equivalent to a new line'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'left bracket'
  '['
  'opens a block'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'right bracket'
  ']'
  'closes a block'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'left parenthesis'
  '('
  'opens an expansion group'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'right parenthesis'
  ')'
  'closes an expansion group'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'asterisk'
  '*'
  'expands a list into individual items'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'single quote'
  '\''
  'opens or closes a string literal'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'escape'
  '\\'
  'prevents a following \' from ending a string literal (use \\\\ for a literal \\)'
 ]
]

get table-row, call [ get syntaxTable ] [
 list [
  'hash'
  '#'
  'marks the rest of the line as a comment'
 ]
]

get header, call 'Crown Keywords' 2

get paragraph, call 'Crown has 4 keywords. Keywords are the only words that are not strings by default. You may wrap a keyword in a string to get the string version, i.e. <code>\'null\'</code>.'

set keywordTable [ get table, call ]

get keywordTable classList add, call code-column-2

get table-row, call [ get keywordTable ] [
 list [ Keyword, Type, Description ]
]

get table-row, call [ get keywordTable ] [
 list [
  'null'
  'object'
  'Null value'
 ]
]

get table-row, call [ get keywordTable ] [
 list [
  'undefined'
  'undefined'
  'Undefined value'
 ]
]

get table-row, call [ get keywordTable ] [
 list [
  'true'
  'boolean'
  'Boolean true'
 ]
]

get table-row, call [ get keywordTable ] [
 list [
  'false'
  'boolean'
  'Boolean false'
 ]
]

get header, call 'Crown Commands' 2

get paragraph, call 'There are many named commands in Crown, as follows:'

set commandTable [ get table, call ]

get commandTable classList add, call code-column-2

get table-row, call [ get commandTable ] [
 list [ Command, 'Example code', Description ]
]

get table-row, call [ get commandTable ] [
 list [ '#'
  '# a comment'
  'Creates a comment' ]
]

get table-row, call [ get commandTable ] [
 list [ '<'
  'value 4, < 5'
  'Returns true if current is less than argument' ]
]

get table-row, call [ get commandTable ] [
 list [ '<='
  'value 5, <= 5'
  'Returns true if current is less than or equal to argument' ]
]

get table-row, call [ get commandTable ] [
 list [ '='
  'value 5, = 5'
  'Returns true if current is equal to argument' ]
]

get table-row, call [ get commandTable ] [
 list [ '>'
  'value 6, >= 5 '
  'Returns true if current is greater than argument' ]
]

get table-row, call [ get commandTable ] [
 list [ '>='
  'value 5, >= 5'
  'Returns true if current is greater than or equal to argument' ]
]

get table-row, call [ get commandTable ] [
 list [ 'add'
  'add 1 2 3'
  'Sums all arguments, and the focus if it is a number (example returns 6)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'all'
  'all true false true'
  'Returns the logical AND of all arguments (example returns false)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'any'
  'any true false true'
  'Returns the logical OR of all arguments (example returns true)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'at'
  'at document body'
  'Sets focus to a property of focus (example will have focus set to <body> element)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'call'
  'at alert, call Hello'
  'Invokes a function (example calls alert with \'Hello\'). Updates the focus to the return value. To retain the function in focus and ignore the return value, use tell instead.' ]
]

get table-row, call [ get commandTable ] [
 list [ 'clear_error'
  'clear_error'
  'Clears a captured error, allowing code walk to proceed.' ]
]

get table-row, call [ get commandTable ] [
 list [ 'clone'
  'clone, set x 4'
  'Clones the current scope, retaining inheritance (in example, new scope has x set to 4)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'comment'
  'log [ comment ]'
  'Returns the last comment (example returns \'a comment\')' ]
]

get table-row, call [ get commandTable ] [
 list [ 'current'
  'value 4, log [ current ]'
  'Returns the implicit focus (example logs \'4\')' ]
]

get table-row, call [ get commandTable ] [
 list [ 'current_error'
  'current_error'
  'Returns the captured error, if any.' ]
]

get table-row, call [ get commandTable ] [
 list [ 'default'
  'get foo, default 4'
  'Returns the argument if the focus is undefined or null' ]
]

get table-row, call [ get commandTable ] [
 list [ 'divide'
  'value 4, divide 2'
  'Divides the focus by the argument(s)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'do'
  'do [ call abc ]'
  'Run some code without modifying the focus' ]
]

get table-row, call [ get commandTable ] [
 list [ 'drop'
  'get items, drop [ is empty ]'
  'Sets current to undefined if any condition is true (keep if all return false)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'each'
  'each [ function item index [ ... ] ]'
  'Calls a function with two arguments for each item in an Array' ]
]

get table-row, call [ get commandTable ] [
 list [ 'entries'
  'entries [ function key value index [ ... ] ]'
  'Calls a function with three arguments for each key value pair in an Object' ]
]

get table-row, call [ get commandTable ] [
 list [ 'error'
  'error Something went wrong'
  'Throws an error with the given message' ]
]

get table-row, call [ get commandTable ] [
 list [ 'false'
  'value 4, > 5, false [ log No ]'
  'Runs the associated code block if focus is falsy This will log \'No\', since 4 is not > 5' ]
]

get table-row, call [ get commandTable ] [
 list [ 'filter'
  'filter [ function item index [ ... ] ]'
  'Filters an array by calling a test function for each item in an Array' ]
]

get table-row, call [ get commandTable ] [
 list [ 'find'
  'find [ function item index [ ... ] ]'
  'Extracts a single item from an array by calling a test function for each item until a match is found' ]
]

get table-row, call [ get commandTable ] [
 list [ 'function'
  'function arg1 arg2 [ ... ]'
  'Creates a function with some named arguments (2 in example) and a function block' ]
]

get table-row, call [ get commandTable ] [
 list [ 'get'
  'log [ get foo ]'
  'Read the name from the current scope (example will log the value of foo)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'get_error'
  'try [ ... ] [ get_error ]'
  'Gets the error message from a try block' ]
]

get table-row, call [ get commandTable ] [
 list [ 'global'
  'log [ global document title ]'
  'Read the name from the global scope (example will log the title of the current document)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'group'
  'group [ function item [ get item key ] ]'
  'Groups an Array by the return value of the given function' ]
]

get table-row, call [ get commandTable ] [
 list [ 'is'
  'value 5, is 5'
  'The same as =' ]
]

get table-row, call [ get commandTable ] [
 list [ 'it'
  'value 5, log [ it ]'
  'Returns the current value (alias for current)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'keep'
  'get items, keep [ is valid ]'
  'Sets current to undefined if all conditions are false (keep if any return true)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'list'
  'list [ 1, 2, 3, 4 ]
# or
list 1 2 3 4'
  'Creates an Array' ]
]

get table-row, call [ get commandTable ] [
 list [ 'load'
  'load ./path/to/file.cr'
  'Loads a Crown module into memory, but does not run it' ]
]

get table-row, call [ get commandTable ] [
 list [ 'log'
  'log foo is [ get foo ]'
  'Logs all arguments to the console (example logs \'foo is 4\' assuming foo = 4)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'loop'
  'value 5, loop [ log [ current ], subtract 1, keep [ > 0 ] ]'
  'Loops while current is defined' ]
]

get table-row, call [ get commandTable ] [
 list [ 'map'
  'map [ function item index [ ... ] ]'
  'Constructs a new Array with the results of calling a function with two arguments for each item in an Array' ]
]

get table-row, call [ get commandTable ] [
 list [ 'multiply'
  'multiply 3 9'
  'Returns the product of all arguments, and the focus if it is a number (example returns 27)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'names'
  'set foo bar, names'
  'Return an object with all names in scope (example returns <code>{foo: "bar"}</code>)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'new'
  'global Date, new'
  'Creates a new instance of a class in focus.' ]
]

get table-row, call [ get commandTable ] [
 list [ 'not'
  'value 4, is 5, not'
  'Boolean invert of focus (example returns true)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'object'
  'object [ a 1, b 2 ]'
  'Creates an object with given key-value pairs (example returns <code>{ a: 1, b: 2 }</code>)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'pick'
  'value 7, pick [ < 5, value small ] [ < 10, value medium ] [ true, value large ]'
  'Selects from multiple options (example returns <code>\'medium\'</code>)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'point'
  'set a [ load ./file.cr, point ]'
  'Invokes focus with the scope as an argument (example runs file.cr, sets a to the result)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'prepend'
  'prepend get [ [ x call ] [ y call ] ]'
  'Prepends commands to each statement in a statement list' ]
]

get table-row, call [ get commandTable ] [
 list [ 'promise'
  'promise [ function resolve reject [ ... ] ]'
  'Returns a promise, which can be resolved or rejected later with e.g. [ get resolve, call 4 ]' ]
]

get table-row, call [ get commandTable ] [
 list [ 'regexp'
  'regexp foo.*'
  'Creates a regular expression' ]
]

get table-row, call [ get commandTable ] [
 list [ 'run'
  'run \'log 42\''
  'Runs string argument as Crown code (example logs 42)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'set'
  'set foo 4'
  'Sets a named variable in scope (example sets foo to 4)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'subtract'
  'value 10, subtract 2 3'
  'Subtracts arguments from focus (example returns 5)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'tap'
  'function scope [ ... ], tap'
  'Calls the current function with the scope as an argument' ]
]

get table-row, call [ get commandTable ] [
 list [ 'tell'
  'at alert, tell Hello'
  'Invokes a function (example calls alert with \'Hello\'). Retains the function in focus and ignores the return value. To access the function\'s return value, use call instead.' ]
]

get table-row, call [ get commandTable ] [
 list [ 'template'
  'template \'Hello, %0\' Human'
  'Inserts arguments into a string given as the first argument (example returns \'Hello, Human\')' ]
]

get table-row, call [ get commandTable ] [
 list [ 'to'
  'value 5, to myVar'
  'Saves the current value to a variable name' ]
]

get table-row, call [ get commandTable ] [
 list [ 'true'
  'value 6, > 5, true [ log Big ]'
  'Runs the associated code block if focus is truthy This will log Big since 6 > 5' ]
]

get table-row, call [ get commandTable ] [
 list [ 'try'
  'try [ error oops ] [ log caught [ get_error ] ]'
  'Tries a code block, runs error handler if an error occurs' ]
]

get table-row, call [ get commandTable ] [
 list [ 'typeof'
  'value 5, typeof'
  'Returns the type of the current value' ]
]

get table-row, call [ get commandTable ] [
 list [ 'unset'
  'unset foo'
  'Forgets a named variable in scope' ]
]

get table-row, call [ get commandTable ] [
 list [ 'value'
  'value 5'
  'Create a literal value (example returns 5)' ]
]

get table-row, call [ get commandTable ] [
 list [ 'will'
  'get myFunc, will arg1 arg2'
  'Creates a function that calls current with the given arguments when invoked' ]
]

get header, call 'About' 2

set about [ get paragraph, call '' ]

get span, call 'Crown is developed by ' [ get about ]

get anchor, call 'Nathanael S Ferrero' https://nateferrero.com [ get about ]

get span, call '. For help and support, or to report bugs so I can fix them, kindly send me an email at ' [ get about ]

get anchor, call nate@tagme.in mailto:nate@tagme.in [ get about ]

get span, call '.' [ get about ]
