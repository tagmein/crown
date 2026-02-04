# Crown

#### Current version: 2026-02-04

#### License: Public domain

Crown is a metaprogramming syntax that can be implemented in any programming environment. You are currently viewing a document written in Crown for JavaScript.

The Crown engine runs code one command at a time, and maintains an 'implicit focus' at all times. This means that the results of the last command are always available for the next command, and so on. A sample Crown program might look like:

```
add 4 5, log The sum is [ current ] # prints 'The sum is 9' to the console
```

## Getting Started

Download a copy of the Crown JavaScript Engine from https://crown.tagme.in/crown.js and add the following code to an HTML file:

```
<!doctype html>
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
    set [ get greeting ] textContent 'Hello, world'
   `
   // or, if your Crown code is in a file:
   // await crown().runFile('./main.cr')
  }
  main().catch(e => console.error(e))
 </script>
</body>

</html>

```

If everything is set up properly, meaning the ./crown.js file is accessible, loading the HTML file in a browser will produce the following:

## Crown Syntax

Crown has only 10 syntax characters: `⏎,[]()*'\#`

| Name | Symbol | Description |
|---|---|---|
| new line |  | separates statements |
| comma | , | separates statements, is equivalent to a new line |
| left bracket | [ | opens a block |
| right bracket | ] | closes a block |
| left parenthesis | ( | opens an expansion group |
| right parenthesis | ) | closes an expansion group |
| asterisk | * | expands a list into individual items |
| single quote | ' | opens or closes a string literal |
| escape | \ | prevents a following ' from ending a string literal (use \\ for a literal \) |
| hash | # | marks the rest of the line as a comment |

## Crown Keywords

Crown has 4 keywords. Keywords are the only words that are not strings by default. You may wrap a keyword in a string to get the string version, i.e. `'null'`.

| Keyword | Type | Description |
|---|---|---|
| null | object | Null value |
| undefined | undefined | Undefined value |
| true | boolean | Boolean true |
| false | boolean | Boolean false |

## Crown Commands

There are many named commands in Crown, as follows:

| Command | Example code | Description |
|---|---|---|
| # | # a comment | Creates a comment |
| < | value 4, < 5 | Returns true if current is less than argument |
| <= | value 5, <= 5 | Returns true if current is less than or equal to argument |
| = | value 5, = 5 | Returns true if current is equal to argument |
| > | value 6, >= 5  | Returns true if current is greater than argument |
| >= | value 5, >= 5 | Returns true if current is greater than or equal to argument |
| add | add 1 2 3 | Sums all arguments, and the focus if it is a number (example returns 6) |
| all | all true false true | Returns the logical AND of all arguments (example returns false) |
| any | any true false true | Returns the logical OR of all arguments (example returns true) |
| at | at document body | Sets focus to a property of focus (example will have focus set to  element) |
| call | at alert, call Hello | Invokes a function (example calls alert with 'Hello'). Updates the focus to the return value. To retain the function in focus and ignore the return value, use tell instead. |
| clear_error | clear_error | Clears a captured error, allowing code walk to proceed. |
| clone | clone, set x 4 | Clones the current scope, retaining inheritance (in example, new scope has x set to 4) |
| comment | log [ comment ] | Returns the last comment (example returns 'a comment') |
| current | value 4, log [ current ] | Returns the implicit focus (example logs '4') |
| current_error | current_error | Returns the captured error, if any. |
| default | get foo, default 4 | Returns the argument if the focus is undefined or null |
| divide | value 4, divide 2 | Divides the focus by the argument(s) |
| do | do [ call abc ] | Run some code without modifying the focus |
| drop | get items, drop [ is empty ] | Sets current to undefined if any condition is true (keep if all return false) |
| each | each [ function item index [ ... ] ] | Calls a function with two arguments for each item in an Array |
| entries | entries [ function key value index [ ... ] ] | Calls a function with three arguments for each key value pair in an Object |
| error | error Something went wrong | Throws an error with the given message |
| false | value 4, > 5, false [ log No ] | Runs the associated code block if focus is falsy This will log 'No', since 4 is not > 5 |
| filter | filter [ function item index [ ... ] ] | Filters an array by calling a test function for each item in an Array |
| find | find [ function item index [ ... ] ] | Extracts a single item from an array by calling a test function for each item until a match is found |
| function | function arg1 arg2 [ ... ] | Creates a function with some named arguments (2 in example) and a function block |
| get | log [ get foo ] | Read the name from the current scope (example will log the value of foo) |
| get_error | try [ ... ] [ get_error ] | Gets the error message from a try block |
| global | log [ global document title ] | Read the name from the global scope (example will log the title of the current document) |
| group | group [ function item [ get item key ] ] | Groups an Array by the return value of the given function |
| is | value 5, is 5 | The same as = |
| it | value 5, log [ it ] | Returns the current value (alias for current) |
| keep | get items, keep [ is valid ] | Sets current to undefined if all conditions are false (keep if any return true) |
| list | list [ 1, 2, 3, 4 ] # or list 1 2 3 4 | Creates an Array |
| load | load ./path/to/file.cr | Loads a Crown module into memory, but does not run it |
| log | log foo is [ get foo ] | Logs all arguments to the console (example logs 'foo is 4' assuming foo = 4) |
| loop | value 5, loop [ log [ current ], subtract 1, keep [ > 0 ] ] | Loops while current is defined |
| map | map [ function item index [ ... ] ] | Constructs a new Array with the results of calling a function with two arguments for each item in an Array |
| multiply | multiply 3 9 | Returns the product of all arguments, and the focus if it is a number (example returns 27) |
| names | set foo bar, names | Return an object with all names in scope (example returns `{foo: "bar"}`) |
| new | global Date, new | Creates a new instance of a class in focus. |
| not | value 4, is 5, not | Boolean invert of focus (example returns true) |
| object | object [ a 1, b 2 ] | Creates an object with given key-value pairs (example returns `{ a: 1, b: 2 }`) |
| pick | value 7, pick [ < 5, value small ] [ < 10, value medium ] [ true, value large ] | Selects from multiple options (example returns `'medium'`) |
| point | set a [ load ./file.cr, point ] | Invokes focus with the scope as an argument (example runs file.cr, sets a to the result) |
| prepend | prepend get [ [ x call ] [ y call ] ] | Prepends commands to each statement in a statement list |
| promise | promise [ function resolve reject [ ... ] ] | Returns a promise, which can be resolved or rejected later with e.g. [ get resolve, call 4 ] |
| regexp | regexp foo.* | Creates a regular expression |
| run | run 'log 42' | Runs string argument as Crown code (example logs 42) |
| set | set foo 4 | Sets a named variable in scope (example sets foo to 4) |
| subtract | value 10, subtract 2 3 | Subtracts arguments from focus (example returns 5) |
| tap | function scope [ ... ], tap | Calls the current function with the scope as an argument |
| tell | at alert, tell Hello | Invokes a function (example calls alert with 'Hello'). Retains the function in focus and ignores the return value. To access the function's return value, use call instead. |
| template | template 'Hello, %0' Human | Inserts arguments into a string given as the first argument (example returns 'Hello, Human') |
| to | value 5, to myVar | Saves the current value to a variable name |
| true | value 6, > 5, true [ log Big ] | Runs the associated code block if focus is truthy This will log Big since 6 > 5 |
| try | try [ error oops ] [ log caught [ get_error ] ] | Tries a code block, runs error handler if an error occurs |
| typeof | value 5, typeof | Returns the type of the current value |
| unset | unset foo | Forgets a named variable in scope |
| value | value 5 | Create a literal value (example returns 5) |
| will | get myFunc, will arg1 arg2 | Creates a function that calls current with the given arguments when invoked |

## About

Crown is developed by [Nathanael S Ferrero](https://nateferrero.com). For help and support, or to report bugs so I can fix them, kindly send me an email at [nate@tagme.in](mailto:nate@tagme.in).

