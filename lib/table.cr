function appendTo [
 set table [ get element, call table ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get table ]
 get table
]
