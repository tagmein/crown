get describe, call 'object commands' [
 function [
  get it, call 'should create objects' [
   function [
    object [ a 1, b 2 ], to result
    get expect, call [ get to-equal ] [ get result, at a ] 1
    get expect, call [ get to-equal ] [ get result, at b ] 2
   ]
  ]
  
  get it, call 'should create objects with computed values' [
   function [
    set x 10
    object [ a [ get x ], b 20 ], to result
    get expect, call [ get to-equal ] [ get result, at a ] 10
    get expect, call [ get to-equal ] [ get result, at b ] 20
   ]
  ]
  
  get it, call 'should create objects with single key' [
   function [
    set x 10
    object [ x ], to result
    get expect, call [ get to-equal ] [ get result, at x ] 10
   ]
  ]
  
  get it, call 'should get entries from objects' [
   function [
    object [ a 1, b 2 ], entries, to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 2
   ]
  ]
  
  get it, call 'should handle empty objects' [
   function [
    object, to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-equal ] [ get result, typeof ] 'object'
   ]
  ]
 ]
]
