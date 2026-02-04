get describe, call 'control flow commands' [
 function [
  get it, call 'should use true for conditional execution' [
   function [
    value true, true
    get expect, call [ get to-be-true ] [ current ]
    value false, true
    get expect, call [ get to-be-true ] [ current ]
   ]
  ]
  
  
  get it, call 'should not execute false block when true' [
   function [
    value true, false [ value 42 ]
    get expect, call [ get to-be-true ] [ current ]
   ]
  ]
  
  get it, call 'should use pick for multiple conditions' [
   function [
    value 7, pick [ < 5, value 'small' ] [ < 10, value 'medium' ] [ true, value 'large' ], to result
    get expect, call [ get to-equal ] [ get result ] 'medium'
   ]
  ]
  
  get it, call 'should use pick with first matching condition' [
   function [
    value 3, pick [ < 5, value 'small' ] [ < 10, value 'medium' ], to result
    get expect, call [ get to-equal ] [ get result ] 'small'
   ]
  ]
  
  get it, call 'should use loop while current is defined' [
   function [
    value 3, loop [ subtract 1, keep [ > 0 ] ], to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should use drop to set undefined when condition is true' [
   function [
    value 5, drop [ value true ], to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
    value 5, drop [ value false ], to result2
    get expect, call [ get to-equal ] [ get result2 ] 5
   ]
  ]
  
  get it, call 'should use keep to set undefined when all conditions false' [
   function [
    value 5, keep [ value false ], to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
    value 5, keep [ value true ], to result2
    get expect, call [ get to-equal ] [ get result2 ] 5
   ]
  ]
 ]
]
