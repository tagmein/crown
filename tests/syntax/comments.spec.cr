get describe, call 'comment syntax' [
 function [
  get it, call 'should parse single line comments' [
   function [
    # This is a comment
    set result 42
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should ignore everything after hash' [
   function [
    set result 42 # this should be ignored
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle multiple comments' [
   function [
    # First comment
    set x 1 # inline comment
    # Second comment
    set y 2
    get expect, call [ get to-equal ] [ get x ] 1
    get expect, call [ get to-equal ] [ get y ] 2
   ]
  ]
  
  get it, call 'should allow comments at end of statements' [
   function [
    set result [ list 1 2 ] # comment here
    get expect, call [ get to-be-array ] [ get result ]
   ]
  ]
 ]
]
