get describe, call 'keyword syntax' [
 function [
  get it, call 'should parse null keyword' [
   function [
    set result null
    get expect, call [ get to-be-null ] [ get result ]
   ]
  ]
  
  get it, call 'should parse undefined keyword' [
   function [
    set result undefined
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should parse true keyword' [
   function [
    set result true
    get expect, call [ get to-be-true ] [ get result ]
   ]
  ]
  
  get it, call 'should parse false keyword' [
   function [
    set result false
    get expect, call [ get to-be-false ] [ get result ]
   ]
  ]
  
  get it, call 'should distinguish keywords from strings' [
   function [
    set keyword-value true
    set string-value 'true'
    get expect, call [ get to-be-true ] [ get keyword-value ]
    get expect, call [ get to-equal ] [ get string-value, typeof ] 'string'
    get expect, call [ get to-equal ] [ get string-value ] 'true'
   ]
  ]
  
  get it, call 'should handle null in comparisons' [
   function [
    set result null
    get expect, call [ get to-equal ] [ get result, is null ] true
   ]
  ]
  
  get it, call 'should handle undefined in comparisons' [
   function [
    set result undefined
    get expect, call [ get to-equal ] [ get result, is undefined ] true
   ]
  ]
 ]
]
