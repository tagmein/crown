get describe, call 'logic commands' [
 function [
  get it, call 'should compute logical AND with all' [
   function [
    all true true true, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    all true false true, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should compute logical OR with any' [
   function [
    any true false false, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    any false false false, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should negate with not' [
   function [
    value true, not, to result1
    get expect, call [ get to-be-false ] [ get result1 ]
    value false, not, to result2
    get expect, call [ get to-be-true ] [ get result2 ]
   ]
  ]
  
  get it, call 'should handle empty all' [
   function [
    all, to result
    get expect, call [ get to-be-true ] [ get result ]
   ]
  ]
  
  get it, call 'should handle empty any' [
   function [
    any, to result
    get expect, call [ get to-be-false ] [ get result ]
   ]
  ]
 ]
]
