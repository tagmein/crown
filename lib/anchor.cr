function text href appendTo [
 set anchor [ get element, call a ]
 get anchor setAttribute
 do [ call href [ get href ] ]
 do [ call target _top ]
 set [ get anchor ] textContent [ get text ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get anchor ]
]
