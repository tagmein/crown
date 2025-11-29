global Date, new, at getMinutes, call

pick [
  < 15
  log first quarter
  value 1
] [
  < 30
  log second quarter
  value 2
] [
  < 45
  log third quarter
  value 3
] [
  true
  log fourth quarter
  value 4
]

log quarter [ current ] of 4
