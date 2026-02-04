get describe, call 'string brackets' [
 function [
  get it, call 'should handle closing bracket in string' [
   function [
    value 'string ] with ending bracket', to result
    get expect, call [ get to-equal ] [ get result ] 'string ] with ending bracket'
   ]
  ]
  
  get it, call 'should handle opening bracket in string' [
   function [
    value 'string [ with opening bracket', to result
    get expect, call [ get to-equal ] [ get result ] 'string [ with opening bracket'
   ]
  ]
  
  get it, call 'should handle both brackets in string' [
   function [
    value 'string [ ] with both brackets', to result
    get expect, call [ get to-equal ] [ get result ] 'string [ ] with both brackets'
   ]
  ]
  
  get it, call 'should handle closing parenthesis in string' [
   function [
    value 'string ) with closing paren', to result
    get expect, call [ get to-equal ] [ get result ] 'string ) with closing paren'
   ]
  ]
  
  get it, call 'should handle opening parenthesis in string' [
   function [
    value 'string ( with opening paren', to result
    get expect, call [ get to-equal ] [ get result ] 'string ( with opening paren'
   ]
  ]
  
  get it, call 'should handle both parentheses in string' [
   function [
    value 'string ( ) with both parens', to result
    get expect, call [ get to-equal ] [ get result ] 'string ( ) with both parens'
   ]
  ]
  
  get it, call 'should handle brackets in object keys' [
   function [
    object [ 'key ] with bracket' 42 ], to result
    get expect, call [ get to-equal ] [ get result, at 'key ] with bracket' ] 42
   ]
  ]
  
  get it, call 'should handle brackets in function arguments' [
   function [
    function x [ value [ get x ] ], call 'test ] string', to result
    get expect, call [ get to-equal ] [ get result ] 'test ] string'
   ]
  ]
 ]
]
