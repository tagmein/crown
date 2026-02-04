get describe, call 'statement syntax' [
 function [
  get it, call 'should parse statements separated by newlines' [
   function [
    set x 1
    set y 2
    get expect, call [ get to-equal ] [ get x ] 1
    get expect, call [ get to-equal ] [ get y ] 2
   ]
  ]
  
  get it, call 'should parse statements separated by commas' [
   function [
    set x 1, set y 2
    get expect, call [ get to-equal ] [ get x ] 1
    get expect, call [ get to-equal ] [ get y ] 2
   ]
  ]
  
  get it, call 'should handle mixed separators' [
   function [
    set x 1, set y 2
    set z 3
    get expect, call [ get to-equal ] [ get x ] 1
    get expect, call [ get to-equal ] [ get y ] 2
    get expect, call [ get to-equal ] [ get z ] 3
   ]
  ]
  
  get it, call 'should parse single statement' [
   function [
    set result 42
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
 ]
]
