get describe, call 'error handling commands' [
 function [
  get it, call 'should throw errors' [
   function [
    get expect-error, call [
     function [
      error 'Test error'
     ]
    ]
   ]
  ]
  
  get it, call 'should catch errors with try' [
   function [
    set caught false
    try [
     error 'Test error'
    ] [
     set caught true
    ]
    get expect, call [ get to-be-true ] [ get caught ]
   ]
  ]
  
  get it, call 'should get error message with get_error' [
   function [
    try [
     error 'Test error message'
    ] [
     get_error, to error-msg
     get expect, call [ get to-contain ] [ get error-msg ] 'Test error message'
    ]
   ]
  ]
  
  get it, call 'should clear errors' [
   function [
    try [
     error 'Test error'
    ] [
     clear_error
     get expect, call [ get to-equal ] [ current_error, typeof ] 'undefined'
    ]
   ]
  ]
  
  get it, call 'should continue execution after error handling' [
   function [
    set x 0
    try [
     error 'Test error'
    ] [
     set x 1
    ]
    get expect, call [ get to-equal ] [ get x ] 1
   ]
  ]
 ]
]
