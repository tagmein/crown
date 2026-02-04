get describe, call 'REPL functionality' [
 function [
  get it, call 'should set prefix for unterminated string' [
   function [
    run 'value hello', to result
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] "'"
   ]
  ]
  ]
  
  get it, call 'should set prefix for unterminated block' [
   function [
    set input1 'value [ 1'
    run [ get input1 ], to result
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
   ]
  ]
  ]
  
  get it, call 'should set prefix for unterminated macro' [
   function [
    set input1 'value ( 1'
    run [ get input1 ], to result
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '('
   ]
  ]
  ]
  
  get it, call 'should clear prefix after completing string' [
   function [
    set input1 'value hello'
    run [ get input1 ], to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    set input2 ' world'
    run [ get input2 ], to result2
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
  
  get it, call 'should clear prefix after completing block' [
   function [
    set input1 'value [ 1'
    run [ get input1 ], to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    set input2 ' 2'
    run [ get input2 ], to result2
    get expect, call [ get to-be-defined ] [ prefix ]
    set input3 ' ]'
    run [ get input3 ], to result3
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
  
  get it, call 'should clear prefix after completing macro' [
   function [
    set input1 'value ( 1'
    run [ get input1 ], to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    set input2 ' 2'
    run [ get input2 ], to result2
    get expect, call [ get to-be-defined ] [ prefix ]
    set input3 ' )'
    run [ get input3 ], to result3
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
  
  get it, call 'should handle multi-line input continuation' [
   function [
    run 'value 1', to result1
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
    run 'value 2, value', to result2
    get expect, call [ get to-be-defined ] [ prefix ]
    run ' 3', to result3
    get expect, call [ get to-equal ] [ current ] 3
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
  
  get it, call 'should handle nested incomplete structures' [
   function [
    set input1 'value [ [ 1'
    run [ get input1 ], to result1
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
    set input2 ' 2'
    run [ get input2 ], to result2
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
    set input3 ' ]'
    run [ get input3 ], to result3
    get expect, call [ get to-be-defined ] [ prefix ]
    get expect, call [ get to-contain ] [ prefix ] '['
    set input4 ' ]'
    run [ get input4 ], to result4
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
  
  get it, call 'should handle comment continuation' [
   function [
    run 'value 1 # comment', to result1
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
    get expect, call [ get to-equal ] [ current ] 1
   ]
  ]
  ]
  
  get it, call 'should handle complete statements without continuation' [
   function [
    run 'value 42', to result
    get expect, call [ get to-equal ] [ current ] 42
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
    run 'add 1 2 3', to result2
    get expect, call [ get to-equal ] [ current ] 6
    get expect, call [ get to-equal ] [ prefix, typeof ] 'undefined'
   ]
  ]
  ]
 ]
]
