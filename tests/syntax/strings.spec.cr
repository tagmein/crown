get describe, call 'string syntax' [
 function [
  get it, call 'should parse simple strings' [
   function [
    set result 'hello'
    get expect, call [ get to-equal ] [ get result ] 'hello'
   ]
  ]
  
  get it, call 'should parse empty strings' [
   function [
    set result ''
    get expect, call [ get to-equal ] [ get result ] ''
    get expect, call [ get to-have-length ] [ get result ] 0
   ]
  ]
  
  get it, call 'should handle escaped quotes' [
   function [
    set result 'hello \'world\''
    get expect, call [ get to-equal ] [ get result ] 'hello \'world\''
   ]
  ]
  
  get it, call 'should handle escaped backslashes' [
   function [
    set result 'hello \\ world'
    get expect, call [ get to-contain ] [ get result ] '\\'
   ]
  ]
  
  get it, call 'should parse strings with spaces' [
   function [
    set result 'hello world'
    get expect, call [ get to-equal ] [ get result ] 'hello world'
   ]
  ]
  
  get it, call 'should parse strings with special characters' [
   function [
    set result 'hello!@#$%^&*'
    get expect, call [ get to-equal ] [ get result ] 'hello!@#$%^&*'
   ]
  ]
  
  get it, call 'should parse strings with newlines' [
   function [
    set result 'hello\nworld'
    get expect, call [ get to-contain ] [ get result ] '\n'
   ]
  ]
 ]
]
