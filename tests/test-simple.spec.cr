get describe, call 'simple test' [
 function [
  get it, call 'should pass a basic equality check' [
   function [
    get expect, call [ get to-equal ] 1 1
   ]
  ]
  
  get it, call 'should pass a true check' [
   function [
    get expect, call [ get to-be-true ] true
   ]
  ]
  
  get it, call 'should detect when values do not match' [
   function [
    # This test verifies that to-equal throws when values don't match
    get expect-error, call [
     function [
      get expect, call [ get to-equal ] 1 2
     ]
    ]
   ]
  ]
  
  get it, call 'should detect when calling undefined function' [
   function [
    # This test verifies that calling an undefined function throws
    get expect-error, call [
     function [
      get undefined-function, call
     ]
    ]
   ]
  ]
  
  get it, call 'should verify expect-error passes when error is thrown' [
   function [
    get expect-error, call [
     function [
      error 'Test error'
     ]
    ]
   ]
  ]
  
  get it, call 'should verify to-be-defined works' [
   function [
    set x 42
    get expect, call [ get to-be-defined ] [ get x ]
   ]
  ]
 ]
]
