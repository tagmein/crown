function text appendTo [
 set pre [ get element, call pre ]
 set [ get pre ] textContent [ get text ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get pre ]
]
