get describe, call 'basePath handling' [
 function [
  get it, call 'should set basePath when loading file' [
   function [
    load test-module.cr, point, to module-scope
    get expect, call [ get to-be-defined ] [ get module-scope ]
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle absolute paths' [
   function [
    global process, at cwd, call, to cwd-value
    template '%0/tests/integration/test-module.cr' [ get cwd-value ], to abs-path
    load [ get abs-path ], point, to module-scope
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should preserve basePath in cloned scopes' [
   function [
    load test-module.cr, point, to module-scope
    get module-scope, clone child-scope
    get expect, call [ get to-be-defined ] [ get child-scope ]
   ]
  ]
  
  get it, call 'should handle basePath override in load' [
   function [
    global process, at cwd, call, to cwd-value
    template '%0/tests/integration' [ get cwd-value ], to base-path-override
    load test-module.cr [ get base-path-override ], point, to module-scope
    get module-scope get, call module-var, to result
    get expect, call [ get to-equal ] [ get result ] 42
   ]
  ]
  
  get it, call 'should handle relative paths from loaded module' [
   function [
    # Test that modules can be loaded and their scope accessed
    load test-module.cr, point, to module-scope
    get expect, call [ get to-be-defined ] [ get module-scope ]
   ]
  ]
 ]
]
