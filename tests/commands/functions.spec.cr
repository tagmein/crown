get describe, call 'function commands' [
 function [
  get it, call 'should create functions' [
   function [
    function x [ value [ get x, multiply 2 ] ], to double
    get double, call 5, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should create functions with multiple arguments' [
   function [
    function x y [ value [ get x, add [ get y ] ] ], to add-func
    get add-func, call 5 3, to result
    get expect, call [ get to-equal ] [ get result ] 8
   ]
  ]
  
  get it, call 'should call functions' [
   function [
    function x [ value [ get x, multiply 2 ] ], call 5, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should use tell to call without capturing return' [
   function [
    function x [ value [ get x, multiply 2 ] ], to func
    get func, tell 5, to func-after
    get expect, call [ get to-equal ] [ get func-after, typeof ] 'function'
   ]
  ]
  
  get it, call 'should use will to create partial function' [
   function [
    function x y [ value [ get x, add [ get y ] ] ], to add-func
    get add-func, will 5, to add-five
    get expect, call [ get to-equal ] [ get add-five, typeof ] 'function'
   ]
  ]
  
  get it, call 'should use tap to call with scope' [
   function [
    function scope [ get scope, set x 42, get x ], tap, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should use point to invoke function with scope' [
   function [
    function scope [ get scope, set x 42, get x ], point, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
 ]
]
