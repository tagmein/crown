# Nested module that loads another module
load test-module.cr, point, to loaded-module
get loaded-module get, call module-var, to module-var-value
set nested-var [ get module-var-value ]
scope
