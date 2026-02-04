get describe, call 'spread operator' [
 function [
  get it, call 'should spread arrays in add' [
   function [
    add * [ list 1 2 3 ], to result
    get expect, call [ get to-equal ] [ get result ] 6
   ]
  ]
  
  get it, call 'should spread arrays in function calls' [
   function [
    function x y z [ value [ get x, add [ get y ], add [ get z ] ] ], to add-three
    get add-three, call * [ list 1 2 3 ], to result
    get expect, call [ get to-equal ] [ get result ] 6
   ]
  ]
 ]
]
