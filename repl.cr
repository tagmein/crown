clone session
global process stdin setEncoding, call utf8

set prompt [ function [
 global process stdout write, call '> '
] ]
get prompt, call

global process stdin on, call data [
 function chunk [
  get session clear_error, call        
  get session run, call [ get chunk trim, call ]
  log [ get session current, call ]
  get prompt, call
 ]
]
