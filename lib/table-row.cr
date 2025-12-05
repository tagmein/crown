function appendTo cells [
 set tableRow [ get element, call tr ]
 get build, call [
  get appendTo, default [ get document body ]
 ] [ get tableRow ]
 get cells, each [
  function cell [
   set tableCell [ get element, call td ]
   set [ get tableCell ] textContent [ get cell ]
   get build, call [ get tableRow ] [
    get tableCell
   ]
  ]
 ]
 get tableRow
]
