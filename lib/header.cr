function text headerLevel appendTo [
 set tagName [
  template h%0 [ get headerLevel, default 1 ]
 ]
 set header [ get element, call [ get tagName ] ]
 set [ get header ] textContent [ get text ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get header ]
]
