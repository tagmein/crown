get describe, call 'run command edge cases' [
 function [
  get it, call 'should handle complete parsing' [
   function [
    run 'value 1, value 2', to result
    get expect, call [ get to-equal ] [ current ] 2
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should handle run with unterminated string' [
   function [
    run 'value \'hello', to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] "'"
   ]
  ]
  
  get it, call 'should handle run with unterminated block' [
   function [
    run 'value [ 1', to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
   ]
  ]
  
  get it, call 'should continue parsing across multiple run calls' [
   function [
    run 'value 1, value', to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    run ' 2', to result2
    get expect, call [ get to-equal ] [ current ] 2
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should continue parsing unterminated string' [
   function [
    run 'value \'hello', to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    run ' world\'', to result2
    get expect, call [ get to-equal ] [ current ] 'hello world'
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should continue parsing unterminated block' [
   function [
    run 'value [ 1', to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    run ' 2 ]', to result2
    get expect, call [ get to-be-array ] [ current ]
    get expect, call [ get to-have-length ] [ current ] 2
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should continue parsing unterminated macro' [
   function [
    run 'value ( 1', to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    run ' 2 )', to result2
    get expect, call [ get to-be-array ] [ current ]
    get expect, call [ get to-have-length ] [ current ] 2
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
 ]
]
