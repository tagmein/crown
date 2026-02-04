get describe, call 'arithmetic commands' [
 function [
  get it, call 'should add numbers' [
   function [
    value 5, add 3 2, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should add with initial value' [
   function [
    value 10, add 5, to result
    get expect, call [ get to-equal ] [ get result ] 15
   ]
  ]
  
  get it, call 'should subtract numbers' [
   function [
    value 10, subtract 3 2, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should multiply numbers' [
   function [
    value 2, multiply 3 4, to result
    get expect, call [ get to-equal ] [ get result ] 24
   ]
  ]
  
  get it, call 'should divide numbers' [
   function [
    value 20, divide 2 2, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should handle zero in addition' [
   function [
    value 5, add 0, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should handle negative numbers' [
   function [
    value 10, add -5, to result
    get expect, call [ get to-equal ] [ get result ] 5
   ]
  ]
  
  get it, call 'should handle floating point arithmetic' [
   function [
    value 1.5, add 2.5, to result
    get expect, call [ get to-equal ] [ get result ] 4
   ]
  ]
 ]
]
