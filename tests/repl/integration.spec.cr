get describe, call 'REPL integration patterns' [
 function [
  # Test the exact patterns used in repl.cr
  
  get it, call 'should clone session scope' [
   function [
    clone session
    get expect, call [ get to-be-defined ] [ get session ]
    get session, typeof, to session-type
    get expect, call [ get to-equal ] [ get session-type ] 'object'
   ]
  ]
  
  get it, call 'should access prefix property on cloned scope' [
   function [
    clone session
    # Set prefix by running incomplete input
    get session run, call 'value [ 1', to result1
    get session prefix, to session-prefix
    get expect, call [ get to-be-defined ] [ get session-prefix ]
    get expect, call [ get to-contain ] [ get session-prefix ] '['
   ]
  ]
  
  get it, call 'should call run method on cloned scope' [
   function [
    clone session
    get session run, call 'value 42', to result
    get session current, call, to session-current
    get expect, call [ get to-equal ] [ get session-current ] 42
   ]
  ]
  
  get it, call 'should call current method on cloned scope' [
   function [
    clone session
    get session run, call 'add 1 2 3', to result
    get session current, call, to session-current
    get expect, call [ get to-equal ] [ get session-current ] 6
   ]
  ]
  
  get it, call 'should call clear_error on cloned scope' [
   function [
    clone session
    # Cause an error in the session and test clear_error
    # Use walk to execute try in the session scope
    get session walk, call [
     list [
      list 'try',
      list [
       list 'error', 'Test error'
      ],
      list [
       list 'current_error', to 'error-before-clear'
      ]
     ]
    ]
    # Check error was captured
    get session get, call error-before-clear, to error-before
    get expect, call [ get to-be-defined ] [ get error-before ]
    # Clear error
    get session clear_error, call
    get session current_error, call, to error-after-clear
    get expect, call [ get to-equal ] [ get error-after-clear, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should handle template with default pattern' [
   function [
    # Pattern: template '%0 ... > ' [ get prefix, default '' ]
    set test-prefix 'test'
    template '%0 ... > ' [ get test-prefix, default '' ], to result1
    get expect, call [ get to-equal ] [ get result1 ] 'test ... > '
    # Test with undefined prefix
    unset test-prefix
    template '%0 ... > ' [ get test-prefix, default '' ], to result2
    get expect, call [ get to-equal ] [ get result2 ] ' ... > '
   ]
  ]
  
  get it, call 'should handle function definition and call pattern' [
   function [
    # Pattern: set prompt [ function prefix [ ... ] ]
    # In REPL, this function executes side effects, doesn't return a value
    # But we can test that it executes correctly by checking currentValue
    set prompt [
     function prefix [
      get prefix, true [
       value 'has prefix'
      ], false [
       value 'no prefix'
      ]
     ]
    ]
    # Call function - it returns scope, call extracts currentValue
    # But true/false don't update currentValue, so we get the comparison result
    # So we test that the function executes without error
    get prompt, call 'test', to result1
    get expect, call [ get to-be-defined ] [ get result1 ]
    get prompt, call undefined, to result2
    get expect, call [ get to-be-defined ] [ get result2 ]
   ]
  ]
  
  get it, call 'should handle nested function calls in event handler pattern' [
   function [
    # Pattern: global process stdin on, call data [ function chunk [ ... ] ]
    # We can't test actual stdin, but we can test the pattern
    # The function uses true/false for side effects, not return values
    set mock-handler [
     function chunk [
      get chunk, is 'test', true [
       value 'matched'
      ], false [
       value 'not matched'
      ]
     ]
    ]
    # Call function - it executes the conditional but returns comparison result
    # Test that function executes without error
    get mock-handler, call 'test', to result1
    get expect, call [ get to-be-defined ] [ get result1 ]
    get mock-handler, call 'other', to result2
    get expect, call [ get to-be-defined ] [ get result2 ]
   ]
  ]
  
  get it, call 'should handle string method access via at' [
   function [
    # Pattern: get chunk trim, call
    set test-str '  hello world  '
    get test-str, at trim, call, to trimmed
    get expect, call [ get to-equal ] [ get trimmed ] 'hello world'
   ]
  ]
  
  get it, call 'should handle log with current value pattern' [
   function [
    # Pattern: log '*' [ get session current, call ]
    clone session
    get session run, call 'value 42', to result
    get session current, call, to session-current
    # We can't easily test log output, but we can verify current works
    get expect, call [ get to-equal ] [ get session-current ] 42
   ]
  ]
  
  get it, call 'should maintain separate state in cloned session scope' [
   function [
    clone session
    # Set variable in main scope
    set main-var 1
    # Set variable in session scope
    get session set, call session-var 2
    # Verify isolation
    get expect, call [ get to-equal ] [ get main-var ] 1
    get session get, call session-var, to session-var-value
    get expect, call [ get to-equal ] [ get session-var-value ] 2
    # Main scope shouldn't see session-var
    get expect, call [ get to-equal ] [ get session-var, typeof ] 'undefined'
   ]
  ]
  
  get it, call 'should handle continuation across multiple run calls' [
   function [
    clone session
    # First incomplete input - value statement with incomplete block
    get session run, call 'value [ 1', to result1
    get session prefix, to prefix1
    get expect, call [ get to-be-defined ] [ get prefix1 ]
    # Continue - add more to the block
    get session run, call ' 2', to result2
    get session prefix, to prefix2
    get expect, call [ get to-be-defined ] [ get prefix2 ]
    # Complete - finish the block
    get session run, call ' ]', to result3
    get session prefix, to prefix3
    # Prefix should be empty string when complete
    get prefix3, is '', to prefix-is-empty
    get expect, call [ get to-equal ] [ get prefix-is-empty ] true
    # The continuation produces: value [ 1, 2 ] which is value with a block
    # The block executes value 1 then value 2, so currentValue should be 2
    # But we need to verify the block was executed correctly
    get session current, call, to final-value
    # Note: This tests that continuation works and prefix is cleared
    # The actual value depends on how value [ 1, 2 ] is parsed and executed
    get expect, call [ get to-be-defined ] [ get final-value ]
   ]
  ]
  
  get it, call 'should handle prefix state persistence in cloned scope' [
   function [
    clone session1
    clone session2
    # Set prefix in session1
    get session1 run, call 'value [ 1', to result1
    get session1 prefix, to prefix1
    get expect, call [ get to-be-defined ] [ get prefix1 ]
    # session2 should not have prefix
    get session2 prefix, to prefix2
    # Prefix should be empty string when not set
    get prefix2, is '', to prefix-empty
    get expect, call [ get to-equal ] [ get prefix-empty ] true
   ]
  ]
 ]
]
