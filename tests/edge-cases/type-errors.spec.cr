get describe, call 'type error cases' [
 function [
  get it, call 'should error when calling non-function' [
   function [
    get expect-error, call [
     function [
      value 42, call
     ]
    ]
   ]
  ]
  
  get it, call 'should error when using array commands on non-arrays' [
   function [
    get expect-error, call [
     function [
      value 'not-array', map [ function x [ value x ] ]
     ]
    ]
   ]
  ]
  
  get it, call 'should error when using entries on non-object' [
   function [
    get expect-error, call [
     function [
      value 42, entries
     ]
    ]
   ]
  ]
  
  get it, call 'should error when accessing property of null' [
   function [
    get expect-error, call [
     function [
      value null, at prop
     ]
    ]
   ]
  ]
  
  get it, call 'should error when setting property of null' [
   function [
    get expect-error, call [
     function [
      value null, to obj
      set obj prop 42
     ]
    ]
   ]
  ]
  
  get it, call 'should error when setting property of non-object' [
   function [
    get expect-error, call [
     function [
      value 42, to num
      set num prop 'value'
     ]
    ]
   ]
  ]
  
  get it, call 'should error when using new on non-constructor' [
   function [
    get expect-error, call [
     function [
      value 'not-constructor', new
     ]
    ]
   ]
  ]
  
  get it, call 'should error when typeof receives arguments' [
   function [
    get expect-error, call [
     function [
      value 42, typeof 1
     ]
    ]
   ]
  ]
 ]
]
