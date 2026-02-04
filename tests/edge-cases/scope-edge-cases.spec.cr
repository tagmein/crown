get describe, call 'scope edge cases' [
 function [
  get it, call 'should handle deep scope inheritance' [
   function [
    set level1 1
    clone level2-scope, get level2-scope set, call level2 [ value 2 ]
    get level2-scope clone, call level3-scope
    get level2-scope get, call level3-scope set, call level3 [ value 3 ]
    get level2-scope get, call level3-scope get, call level1, to result1
    get level2-scope get, call level3-scope get, call level2, to result2
    get expect, call [ get to-equal ] [ get result1 ] 1
    get expect, call [ get to-equal ] [ get result2 ] 2
   ]
  ]
  
  get it, call 'should shadow parent scope variables' [
   function [
    set x 'parent'
    clone child-scope, get child-scope set, call x [ value 'child' ]
    get expect, call [ get to-equal ] [ get x ] 'parent'
    get child-scope get, call x, to child-x
    get expect, call [ get to-equal ] [ get child-x ] 'child'
   ]
  ]
  
  get it, call 'should handle unset in nested scopes' [
   function [
    set x 1
    clone child-scope, get child-scope set, call x [ value 2 ]
    get child-scope unset, call x
    get child-scope get, call x, to result
    get expect, call [ get to-equal ] [ get result ] 1
   ]
  ]
  
  get it, call 'should handle names across scopes' [
   function [
    set x 1
    clone child-scope, get child-scope set, call y [ value 2 ]
    names, to parent-names
    get child-scope names, call, to child-names
    get parent-names, at get, call x, to parent-x
    get expect, call [ get to-equal ] [ get parent-x ] 1
    # x is inherited, so check via get, not names
    get child-scope get, call x, to child-x
    get expect, call [ get to-equal ] [ get child-x ] 1
    get child-names, at get, call y, to child-y
    get expect, call [ get to-equal ] [ get child-y ] 2
   ]
  ]
  
  get it, call 'should handle global access from nested scope' [
   function [
    clone nested-scope
    get nested-scope global, call Math, at PI, to pi-value
    get expect, call [ get to-be-defined ] [ get pi-value ]
   ]
  ]
 ]
]
