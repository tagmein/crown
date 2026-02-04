get describe, call 'special commands' [
 function [
  get it, call 'should use at to access properties' [
   function [
    object [ a 1, b 2 ], at a, to result
    get expect, call [ get to-equal ] [ get result ] 1
   ]
  ]
  
  get it, call 'should use at with multiple segments' [
   function [
    object [ a [ object [ b 2 ] ] ], at a b, to result
    get expect, call [ get to-equal ] [ get result ] 2
   ]
  ]
  
  get it, call 'should use template for string formatting' [
   function [
    template 'Hello, %0' 'World', to result
    get expect, call [ get to-equal ] [ get result ] 'Hello, World'
   ]
  ]
  
  get it, call 'should use template with multiple parameters' [
   function [
    template 'Hello, %0 and %1' 'Alice' 'Bob', to result
    get expect, call [ get to-contain ] [ get result ] 'Alice'
    get expect, call [ get to-contain ] [ get result ] 'Bob'
   ]
  ]
  
  get it, call 'should use typeof to get type' [
   function [
    value 42, typeof, to result
    get expect, call [ get to-equal ] [ get result ] 'number'
    value 'hello', typeof, to result2
    get expect, call [ get to-equal ] [ get result2 ] 'string'
   ]
  ]
  
  get it, call 'should use do to execute without changing focus' [
   function [
    value 42, do [ value 100 ], to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should use comment to get last comment' [
   function [
    # This is a test comment
    comment, to result
    get expect, call [ get to-be-defined ] [ get result ]
   ]
  ]
  
  get it, call 'should use new to create instances' [
   function [
    global Date, new, to date-instance
    get expect, call [ get to-equal ] [ get date-instance, typeof ] 'object'
   ]
  ]
  
  get it, call 'should use regexp to create regular expressions' [
   function [
    regexp 'test.*', to result
    get expect, call [ get to-equal ] [ get result, typeof ] 'object'
    get expect, call [ get to-equal ] [ get result, at test, call 'test123' ] true
   ]
  ]
 ]
]
