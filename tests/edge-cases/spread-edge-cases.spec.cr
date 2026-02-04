get describe, call 'spread operator edge cases' [
 function [
  get it, call 'should handle multiple spreads' [
   function [
    add * [ list 1 2 ] * [ list 3 4 ], to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should handle spread with empty array' [
   function [
    add * [ list ], to result
    get expect, call [ get to-equal ] [ get result ] 0
   ]
  ]
  
  get it, call 'should handle spread in object creation' [
   function [
    function x y [ object [ a [ get x ], b [ get y ] ] ], to make-obj
    get make-obj, call * [ list 1 2 ], to result
    get expect, call [ get to-equal ] [ get result, at a ] 1
    get expect, call [ get to-equal ] [ get result, at b ] 2
   ]
  ]
 ]
]
