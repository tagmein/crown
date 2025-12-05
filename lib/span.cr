function text appendTo [
 set span [ get element, call span ]
 set [ get span ] textContent [ get text ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get span ]
]
