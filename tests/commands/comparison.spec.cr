get describe, call 'comparison commands' [
 function [
  get it, call 'should compare less than' [
   function [
    value 4, < 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 5, < 4, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should compare less than or equal' [
   function [
    value 4, <= 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 5, <= 5, to result2
    get expect, call [ get to-be-true ] [ get result2 ]
    value 6, <= 5, to result3
    get expect, call [ get to-be-false ] [ get result3 ]
   ]
  ]
  
  get it, call 'should compare equal' [
   function [
    value 5, = 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 5, = 4, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should compare greater than' [
   function [
    value 6, > 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 4, > 5, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should compare greater than or equal' [
   function [
    value 6, >= 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 5, >= 5, to result2
    get expect, call [ get to-be-true ] [ get result2 ]
    value 4, >= 5, to result3
    get expect, call [ get to-be-false ] [ get result3 ]
   ]
  ]
  
  get it, call 'should use is command' [
   function [
    value 5, is 5, to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 5, is 4, to result2
    get expect, call [ get to-be-false ] [ get result2 ]
   ]
  ]
  
  get it, call 'should compare strings' [
   function [
    value 'apple', < 'banana', to result1
    get expect, call [ get to-be-true ] [ get result1 ]
    value 'banana', = 'banana', to result2
    get expect, call [ get to-be-true ] [ get result2 ]
   ]
  ]
 ]
]
