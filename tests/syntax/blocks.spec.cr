get describe, call 'block syntax' [
 function [
  get it, call 'should parse simple blocks' [
   function [
    set result [ value 42 ]
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should parse nested blocks' [
   function [
    set result [ list [ value 1, value 2 ] ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 2
   ]
  ]
  
  get it, call 'should parse multiple statements in a block' [
   function [
    set result [ list [ value 1, value 2, value 3 ] ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 3
   ]
  ]
  
  get it, call 'should handle empty blocks' [
   function [
    set x 0
    set result [ ]
    get expect, call [ get to-equal ] [ get x ] 0
   ]
  ]
  
  get it, call 'should parse blocks with commas as separators' [
   function [
    set result [ list [ value 1, value 2 ] ]
    get expect, call [ get to-be-array ] [ get result ]
    get expect, call [ get to-have-length ] [ get result ] 2
   ]
  ]
 ]
]
