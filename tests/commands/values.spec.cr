get describe, call 'value commands' [
 function [
  get it, call 'should create values with value command' [
   function [
    value 42, to result1
    get expect, call [ get to-equal ] [ get result1 ] 42
    value 'hello', to result2
    get expect, call [ get to-equal ] [ get result2 ] 'hello'
   ]
  ]
  
  get it, call 'should get current value' [
   function [
    value 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should get current value with it' [
   function [
    value 42, to result
    get result, it, to it-result
    get expect, call [ get to-equal ] [ get it-result ] 42
   ]
  ]
  
  get it, call 'should use default for undefined' [
   function [
    get undefined-var, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should use default for null' [
   function [
    value null, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should not use default for defined values' [
   function [
    value 10, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should use default for NaN' [
   function [
    value NaN, default 42, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
 ]
]
