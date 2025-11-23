clone session
global process stdin setEncoding, call utf8

set prompt [
 function prefix [
  get prefix, true [
   global process stdout write, call [
    template '%0 ... > ' [ get prefix, default '' ]
   ]
  ], false [
   global process stdout write, call '> '
  ]
 ]
]
get prompt, call

global process stdin on, call data [
 function chunk [
  get chunk trim, call, is 'clear', true [
   global setTimeout
   call [ function [
     global console clear, call
     get prompt, call [ get session prefix ]
   ] ]
  ]
  false [
   get session clear_error, call
   get session run, call [ get chunk ]
   get session prefix, false [
    log '*' [ get session current, call ]
   ]
   get prompt, call [ get session prefix ]
  ]
 ]
]
