get describe, call 'array commands' [
 function [
  get it, call 'should create lists' [
   function [
    list 1 2 3, to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
   ]
  ]
  
  get it, call 'should create lists from block' [
   function [
    list [ value 1, value 2, value 3 ], to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
   ]
  ]
  
  get it, call 'should map arrays' [
   function [
    list 1 2 3, map [ function x [ value [ get x, multiply 2 ] ] ], to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
    get expect, call [ get to-equal ] [ get result, at 0 ] 2
    get expect, call [ get to-equal ] [ get result, at 1 ] 4
    get expect, call [ get to-equal ] [ get result, at 2 ] 6
   ]
  ]
  
  get it, call 'should filter arrays' [
   function [
    list 1 2 3 4 5, filter [ function x [ value [ get x, > 2 ] ] ], to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
    get expect, call [ get to-equal ] [ get result, at 0 ] 3
   ]
  ]
  
  get it, call 'should find items in arrays' [
   function [
    list 1 2 3 4 5, find [ function x [ value [ get x, > 3 ] ] ], to result
    get expect, call [ get to-equal ] [ get result ] 4
   ]
  ]
  
  get it, call 'should return undefined when find fails' [
   function [
    list 1 2 3, find [ function x [ value [ get x, > 10 ] ] ], to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should iterate with each' [
   function [
    list 1 2 3, each [ function x i [ value [ get x, multiply [ get i ] ] ] ], to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
    get expect, call [ get to-equal ] [ get result, at 0 ] 0
    get expect, call [ get to-equal ] [ get result, at 1 ] 2
    get expect, call [ get to-equal ] [ get result, at 2 ] 6
   ]
  ]
  
  get it, call 'should group arrays' [
   function [
    list [ value 'a', value 1 ] [ value 'b', value 2 ] [ value 'a', value 3 ], group [ function item [ get item, at 0 ] ], to result
    get expect, call [ get to-be-defined ] [ get result ]
    get expect, call [ get to-equal ] [ get result, typeof ] 'object'
   ]
  ]
  
  get it, call 'should handle empty arrays' [
   function [
    list, to result
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 0
   ]
  ]
 ]
]
