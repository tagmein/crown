set ( fs, path ) [ global import, call ( fs/promises, path ) ]

# Flag to indicate test mode - modules can check this to avoid side effects
set is_test true

# Get test filter from environment variable
# Usage: TEST_FILTER=path ./crown tests.cr
# Examples:
#   ./crown tests.cr                                    - run all tests
#   TEST_FILTER=components ./crown tests.cr       - run only component tests  
#   TEST_FILTER=api ./crown tests.cr              - run only API tests
#   TEST_FILTER=components/tab-bar.spec.cr ./crown tests.cr - run single test file
set test-filter [ global process env TEST_FILTER ]

set find-spec-files [
 function dir [
  set files [ list ]
  set entries [ global fs readdir, call [ get dir ] [ object [ withFileTypes true ] ] ]
  get entries, map [
   function entry [
    set entry-path [ global path join, call [ get dir ] [ get entry name ] ]
    get entry isDirectory, call, true [
     set sub-files [ get find-spec-files, call [ get entry-path ] ]
     get sub-files, map [
      function file [
       get files push, call [ get file ]
      ]
     ]
    ], false [
     get entry name, pick [
      value [ at endsWith, call .spec.cr ]
      get files push, call [ get entry-path ]
     ] [
      true
      # skip non-spec files
     ]
    ]
   ]
  ]
  get files
 ]
]

set test-results [
 object [
  passed [ list ]
  failed [ list ]
  total 0
 ]
]

set describe [
 function name tests [
  log [ template '  %0' [ get name ] ]
  get tests, call
 ]
]

set it [
 function name test-fn [
  set test-name [ template '    %0' [ get name ] ]
  clear_error
  set test-error null
  try [
   get test-fn, call
  ] [
   # Error occurred - capture it
   get_error, to test-error
  ]
  get test-error, true [
   # test-error is truthy, so it's an error message (string) - test failed
   get test-results failed push, call [ get test-name ]
   set test-results total [ get test-results total, add 1 ]
   log [ template '%0 ✗' [ get test-name ] ]
   log [ template '      Error: %0' [ get test-error ] ]
   clear_error
  ], false [
   # test-error is falsy (null or undefined), so no error - test passed
   get test-results passed push, call [ get test-name ]
   set test-results total [ get test-results total, add 1 ]
   log [ template '%0 ✓' [ get test-name ] ]
  ]
 ]
]

set expect [
 function matcher actual expected [
  # Check if expected is defined (not undefined) rather than truthy
  # This allows comparing to 0, false, null, empty string, etc.
  get expected, typeof, is undefined, true [
   get matcher, call [ get actual ]
  ], false [
   get matcher, call [ get actual ] [ get expected ]
  ]
 ]
]

set to-equal [
 function actual expected [
  get actual, is [ get expected ], true [
   true
  ], false [
   error [ template 'Expected %0 to equal %1' [ get actual ] [ get expected ] ]
  ]
 ]
]

set to-be-null [
 function actual [
  get actual, is null, true [
   true
  ], false [
   throw [ template 'Expected %0 to be null' [ get actual ] ]
  ]
 ]
]

set to-be-true [
 function actual [
  get actual, true [
   true
  ], false [
   throw [ template 'Expected %0 to be true' [ get actual ] ]
  ]
 ]
]

set to-be-false [
 function actual [
  get actual, false [
   true
  ], true [
   throw [ template 'Expected %0 to be false' [ get actual ] ]
  ]
 ]
]

# Matcher for greater than
set to-be-greater-than [
 function actual expected [
  get actual, > [ get expected ], true [
   true
  ], false [
   error [ template 'Expected %0 to be greater than %1' [ get actual ] [ get expected ] ]
  ]
 ]
]

# Matcher for less than
set to-be-less-than [
 function actual expected [
  get actual, < [ get expected ], true [
   true
  ], false [
   error [ template 'Expected %0 to be less than %1' [ get actual ] [ get expected ] ]
  ]
 ]
]

# Matcher for array/string contains
set to-contain [
 function actual expected [
  get actual indexOf, call [ get expected ], >= 0, true [
   true
  ], false [
   error [ template 'Expected %0 to contain %1' [ get actual ] [ get expected ] ]
  ]
 ]
]

# Matcher that expects a function to throw an error
# Usage: get expect-error, call [ function [ ... code that should error ... ] ]
# This is a special matcher that doesn't use the normal expect pattern
set expect-error [
 function test-fn [
  set result [ object [ threw false ] ]
  try [
   get test-fn, call
  ] [
   set result threw true
  ]
  get result threw, false [
   error 'Expected function to throw an error, but it did not'
  ]
  true
 ]
]

# Matcher that expects a value to be defined (not undefined)
set to-be-defined [
 function actual [
  get actual, typeof, is undefined, true [
   error 'Expected value to be defined, but got undefined'
  ], false [
   true
  ]
 ]
]

# Matcher that expects a value to be an array
set to-be-array [
 function actual [
  global Array isArray, call [ get actual ], true [
   true
  ], false [
   error [ template 'Expected %0 to be an array' [ get actual ] ]
  ]
 ]
]

# Matcher for array length
set to-have-length [
 function actual expected [
  get actual length, is [ get expected ], true [
   true
  ], false [
   error [ template 'Expected array length %0 to equal %1' [ get actual length ] [ get expected ] ]
  ]
 ]
]

# Filter spec files based on test-filter argument
set filter-spec-files [
 function files [
  get test-filter, false [
   # No filter - return all files
   get files
  ], true [
   # Filter files that match the path
   get files, filter [
    function file [
     get file, at startsWith, call [ get test-filter ]
    ]
   ]
  ]
 ]
]

set run-tests [
 function [
  get test-filter, true [
   log [ template 'Running tests matching: %0' [ get test-filter ] ]
  ], false [
   log 'Running all tests...'
  ]
  log ''
  
  # Determine base directory - search from project root
  set base-dir '.'
  
  set spec-files [ list ]
  
  get test-filter, true [
   # Check if filter is a specific .spec.cr file
   get test-filter, at endsWith, call .spec.cr, true [
    # Single file specified
    get spec-files push, call [ get test-filter ]
   ], false [
    # Assume it's a directory - search within it
    set found-files [ get find-spec-files, call [ get test-filter ] ]
    get found-files, each [
     function f [
      get spec-files push, call [ get f ]
     ]
    ]
   ]
  ], false [
   # No filter - find all spec files
   set all-files [ get find-spec-files, call [ get base-dir ] ]
   get all-files, each [
    function f [
     get spec-files push, call [ get f ]
    ]
   ]
  ]
  
  get spec-files length, = 0, true [
   log 'No test files found matching filter.'
   global process exit, call 1
  ]
  
  get spec-files, map [
   function file [
    log [ template 'Running %0...' [ get file ] ]
    try [
     load [ get file ], point
    ] [
     log [ template 'Error loading %0: %1' [ get file ] [ current_error ] ]
    ]
    log ''
   ]
  ]
  log ''
  log 'Test Results:'
  log [ template '  Total: %0' [ get test-results total ] ]
  log [ template '  Passed: %0' [ get test-results passed length ] ]
  log [ template '  Failed: %0' [ get test-results failed length ] ]
  get test-results failed length, > 0, true [
   log ''
   log 'Failed tests:'
   get test-results failed, map [
    function test [
     log [ template '  - %0' [ get test ] ]
    ]
   ]
   global process exit, call 1
  ]
 ]
]

get run-tests, call
