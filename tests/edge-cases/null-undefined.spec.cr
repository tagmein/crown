get describe, call 'null and undefined edge cases' [
 function [
  get it, call 'should handle null in arithmetic' [
   function [
    value null, add 5, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should handle undefined in arithmetic' [
   function [
    value undefined, add 5, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should handle null in comparisons' [
   function [
    value null, = null, to result
    get expect, call [ get to-be-true ] [ get result ]
    value null, = undefined, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should handle undefined property access' [
   function [
    object [ a 1 ], at b, to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should handle null with default' [
   function [
    value null, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle undefined with default' [
   function [
    get undefined-var, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle NaN with default' [
   function [
    value NaN, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle null in object creation' [
   function [
    object [ a null, b undefined ], to result
    get expect, call [ get to-be-null ] [ get result, at a ]
    get expect, call [ get to-equal ] [ get result, at b, typeof ] 'undefined'
   ]
  ]
 ]
]
