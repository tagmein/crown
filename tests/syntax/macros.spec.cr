get describe, call 'macro expansion syntax' [
 function [
  get it, call 'should parse macro expansions' [
   function [
    set result [ list ( value 1, value 2 ) ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 2
   ]
  ]
  
  get it, call 'should expand macros with multiple items' [
   function [
    set result [ list ( value 1, value 2, value 3 ) ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 2
   ]
  ]
  
  get it, call 'should handle nested macros' [
   function [
    set result [ list ( value 1, value 2 ) ( value 3, value 4 ) ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 4
   ]
  ]
 ]
]
