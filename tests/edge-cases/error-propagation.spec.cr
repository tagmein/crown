get describe, call 'error propagation edge cases' [
 function [
  get it, call 'should propagate errors from nested function calls' [
   function [
    function x [ error 'Nested error' ], to error-func
    get expect-error, call [
     function [
      get error-func, call 1
     ]
    ]
   ]
  ]
  
  get it, call 'should stop walk on error' [
   function [
    set x 0
    try [
     value 1, error 'Stop here', set x 1
    ] [
     set x 2
    ]
    get expect, call [ get to-equal ] [ get x ] 2
   ]
  ]
  
  get it, call 'should propagate errors from cloned scopes' [
   function [
    clone nested-scope, set nested-scope x [ function [ error 'Cloned error' ] ]
    get expect-error, call [
     function [
      get nested-scope, get x, call
     ]
    ]
   ]
  ]
  
  get it, call 'should handle current_error access' [
   function [
    try [
     error 'Test error'
    ] [
     current_error, to error-msg
     get expect, call [ get to-contain ] [ get error-msg ] 'Test error'
    ]
   ]
  ]
  
  get it, call 'should clear error and continue' [
   function [
    try [
     error 'Test error'
    ] [
     clear_error
     value 42, to result
     get expect, call [ get to-equal ] [ get result ] 42
    ]
   ]
  ]
 ]
]
