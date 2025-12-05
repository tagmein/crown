function text appendTo [
 set p [ get element, call p ]
 set [ get p ] innerHTML [ get text ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get p ]
 get p
]
