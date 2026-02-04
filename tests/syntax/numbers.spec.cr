get describe, call 'number syntax' [
 function [
  get it, call 'should parse integers' [
   function [
    set result 42
    get expect, call [ get to-equal ] [ get result ] 42
    get expect, call [ get to-equal ] [ get result, typeof ] 'number'
   ]
  ]
  
  get it, call 'should parse zero' [
   function [
    set result 0
    get expect, call [ get to-equal ] [ get result ] 0
   ]
  ]
  
  get it, call 'should parse negative numbers' [
   function [
    set result -42
    get expect, call [ get to-equal ] [ get result ] -42
   ]
  ]
  
  get it, call 'should parse floating point numbers' [
   function [
    set result 3.14
    get expect, call [ get to-equal ] [ get result ] 3.14
   ]
  ]
  
  get it, call 'should parse decimal numbers less than one' [
   function [
    set result 0.5
    get expect, call [ get to-equal ] [ get result ] 0.5
   ]
  ]
  
  get it, call 'should parse large numbers' [
   function [
    set result 1000000
    get expect, call [ get to-equal ] [ get result ] 1000000
   ]
  ]
 ]
]
