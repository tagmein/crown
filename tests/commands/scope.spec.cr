get describe, call 'scope commands' [
 function [
  get it, call 'should set and get variables' [
   function [
    set x 42
    get expect, call [ get to-equal ] [ get x ] 42
   ]
  ]
  
  get it, call 'should update variables' [
   function [
    set x 10
    set x 20
    get expect, call [ get to-equal ] [ get x ] 20
   ]
  ]
  
  get it, call 'should use to command' [
   function [
    value 42, to x
    get expect, call [ get to-equal ] [ get x ] 42
   ]
  ]
  
  get it, call 'should unset variables' [
   function [
    set x 42
    unset x
    get expect, call [ get to-equal ] [ get x, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should clone scope' [
   function [
    set x 10
    clone cloned-scope, set cloned-scope y 20
    get expect, call [ get to-equal ] [ get x ] 10
    get expect, call [ get to-equal ] [ get y, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should inherit from parent scope' [
   function [
    set x 10
    clone cloned-scope, set cloned-scope y 20
    get cloned-scope, get x, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should get names' [
   function [
    set x 10
    set y 20
    names, to names-map
    get expect, call [ get to-be-defined ] [ get names-map ]
    get names-map, at get, call x, to x-value
    get expect, call [ get to-equal ] [ get x-value ] 10
    get names-map, at get, call y, to y-value
    get expect, call [ get to-equal ] [ get y-value ] 20
   ]
  ]
  
  get it, call 'should access global scope' [
   function [
    global Math, at PI, to pi-value
    get expect, call [ get to-be-defined ] [ get pi-value ]
    get expect, call [ get to-equal ] [ get pi-value, typeof ] 'number'
   ]
  ]
 ]
]
