get describe, call 'parser error cases' [
 function [
  get it, call 'should handle unmatched closing bracket' [
   function [
    get expect-error, call [
     function [
      run 'value 1 ]'
     ]
    ]
   ]
  ]
  
  get it, call 'should handle unmatched closing parenthesis' [
   function [
    get expect-error, call [
     function [
      run 'value 1 )'
     ]
    ]
   ]
  ]
  
  get it, call 'should handle unterminated string' [
   function [
    run 'value \'hello', to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] "'"
   ]
  ]
  
  get it, call 'should handle unterminated block' [
   function [
    run 'value [ 1', to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
   ]
  ]
  
  get it, call 'should handle unterminated macro' [
   function [
    run 'value ( 1', to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '('
   ]
  ]
  
  get it, call 'should handle unexpected spread operator' [
   function [
    get expect-error, call [
     function [
      list *
     ]
    ]
   ]
  ]
  
  get it, call 'should handle spread without array' [
   function [
    get expect-error, call [
     function [
      list * 5
     ]
    ]
   ]
  ]
 ]
]
