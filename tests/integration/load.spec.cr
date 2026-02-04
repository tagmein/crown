get describe, call 'load command integration' [
 function [
  get it, call 'should load a module file' [
   function [
    load test-module.cr, point, to module-scope
    get expect, call [ get to-be-defined ] [ get module-scope ]
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should load module and access its function' [
   function [
    load test-module.cr, point, to module-scope
    get module-scope get, call module-function, call 5, to result
    get expect, call [ get to-equal ] [ get result ] 10
   ]
  ]
  
  get it, call 'should handle nested module loading' [
   function [
    # Test that nested modules can be loaded
    load nested-module.cr, point, to nested-scope
    get expect, call [ get to-be-defined ] [ get nested-scope ]
   ]
  ]
  
  get it, call 'should preserve basePath for relative loads' [
   function [
    load test-module.cr, point, to module-scope
    get expect, call [ get to-be-defined ] [ get module-scope ]
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle load without point' [
   function [
    load test-module.cr, to module-func
    get expect, call [ get to-equal ] [ get module-func, typeof ] 'function'
    get module-func, point, to module-scope
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should error on non-existent file' [
   function [
    get expect-error, call [
     function [
      load non-existent.cr
     ]
    ]
   ]
  ]
 ]
]
