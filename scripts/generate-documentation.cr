# Generate documentation.md from documentation.cr
# Uses a mock DOM harness to run documentation.cr and convert to markdown

# Set up mock DOM

# Get special characters
global String fromCharCode, call 10, to nl
global String fromCharCode, call 39, to sq
global String fromCharCode, call 92, to bs

# Get project root path (parent of scripts directory)
global basePath, to projectRoot

# Create a container object to hold our mock elements and state
set dom [ object [
  elements [ list ]
  nextId 0
] ]

# Helper to create a mock element
set createElement [ function tagName [
  set id [ get dom nextId ]
  set [ get dom ] nextId [ add [ get id ] 1 ]
  
  set el [ object [
    _id [ get id ]
    tagName [ get tagName ]
    textContent ''
    innerHTML ''
    children [ list ]
    attributes [ object ]
  ] ]
  
  # Store reference to children for closure
  set elChildren [ get el children ]
  set elAttrs [ get el attributes ]
  
  # Add methods
  set [ get el ] appendChild [ function child [
    get elChildren push, call [ get child ]
    get child
  ] ]
  
  set [ get el ] setAttribute [ function name value [
    set [ get elAttrs ] [ get name ] [ get value ]
  ] ]
  
  # Add classList
  set elClasses [ list ]
  set [ get el ] classList [ object [
    _classes [ get elClasses ]
    add [ function className [
      get elClasses push, call [ get className ]
    ] ]
  ] ]
  
  # Track element
  get dom elements, at push, call [ get el ]
  
  get el
] ]

# Create mock body and head
set mockBody [ get createElement, call body ]
set mockHead [ get createElement, call head ]

# Create mock document
set mockDocument [ object [
  title ''
  body [ get mockBody ]
  head [ get mockHead ]
  createElement [ get createElement ]
] ]

# Create mock location
set mockLocation [ object [
  origin 'https://crown.tagme.in'
  pathname '/documentation.cr'
  href 'https://crown.tagme.in/documentation.cr'
] ]

# Set globals - first reset currentValue to globalThis
at [ global ]
set [ global ] document [ get mockDocument ]
at [ global ]
set [ global ] location [ get mockLocation ]

# Also set in local scope
set document [ get mockDocument ]
set location [ get mockLocation ]


# Load and run documentation.cr using load/point to get correct basePath
# Load from parent directory - this sets basePath correctly inside documentation.cr
# Pass globalThis so documentation.cr can access document/location via 'at'
load ../documentation.cr, point [ global ]

# Now convert DOM to markdown

# Helper to strip HTML tags and convert entities
set htmlToText [ function html [
  get html
  at replace, call '<code>' '`'
  at replace, call '</code>' '`'
  at replace, call '&lt;' '<'
  at replace, call '&gt;' '>'
  at replace, call '&amp;' '&'
  at replace, call '&quot;' '"'
  at replace, call [ regexp '<[^>]*>' g ] ''
] ]

# Build markdown from DOM
set mdParts [ list ]

# Process each child of body
get mockBody children, each [ function el [
  set tag [ get el tagName ]
  set text [ get el textContent ]
  set html [ get el innerHTML ]
  set children [ get el children ]
  
  # Get content - prefer textContent, fallback to innerHTML (using object for scoping)
  set contentObj [ object [ value [ get text ] ] ]
  get contentObj value, at length, = 0, true [
    set [ get contentObj ] value [ get htmlToText, call [ get html ] ]
  ]
  set content [ get contentObj value ]
  
  
  # Convert based on tag - using object to store result since true[] runs in child scope
  set out [ object [ value '' ] ]
  
  get tag, = h1, true [ set [ get out ] value [ template '# %0%1%1' [ get text ] [ get nl ] ] ]
  get tag, = h2, true [ set [ get out ] value [ template '## %0%1%1' [ get text ] [ get nl ] ] ]
  get tag, = h3, true [ set [ get out ] value [ template '### %0%1%1' [ get text ] [ get nl ] ] ]
  get tag, = h4, true [ set [ get out ] value [ template '#### %0%1%1' [ get text ] [ get nl ] ] ]
  get tag, = p, true [
    # Check if paragraph has children (like spans and anchors)
    get children, at length, > 0, true [
      set pParts [ list ]
      get children, each [ function child [
        set childTag [ get child tagName ]
        set childText [ get child textContent ]
        set childHref [ get child attributes href ]
        
        # Handle anchor elements
        get childTag, = a, true [
          get pParts, at push, call [ template '[%0](%1)' [ get childText ] [ get childHref ] ]
        ]
        # Handle span elements
        get childTag, = span, true [
          get pParts, at push, call [ get childText ]
        ]
      ] ]
      set [ get out ] value [ template '%0%1%1' [ get pParts, at join, call '' ] [ get nl ] ]
    ]
    # Otherwise use content (textContent or innerHTML)
    get children, at length, = 0, true [
      set [ get out ] value [ template '%0%1%1' [ get content ] [ get nl ] ]
    ]
  ]
  get tag, = pre, true [ set [ get out ] value [ template '```%0%1%0```%0%0' [ get nl ] [ get text ] ] ]
  
  get tag, = table, true [
    # Build table markdown
    set tableParts [ list ]
    set tableState [ object [ firstRow true ] ]
    
    get children, each [ function row [
      set rowParts [ list '|' ]
      get row children, each [ function cell [
        set cellContent [ get cell innerHTML, default [ get cell textContent ] ]
        set cellText [ get htmlToText, call [ get cellContent ] ]
        set cellText [ get cellText, at replace, call [ regexp '\\n' g ] ' ' ]
        get rowParts, at push, call [ template ' %0 |' [ get cellText ] ]
      ] ]
      get tableParts, at push, call [ get rowParts, at join, call '' ]
      
      # Add separator after first row
      get tableState firstRow, true [
        set numCols [ get row children, at length ]
        set sepParts [ list '|' ]
        list 1 2 3 4 5 6 7 8 9 10, each [ function i [
          get i, <= [ get numCols ], true [
            get sepParts, at push, call '---|'
          ]
        ] ]
        get tableParts, at push, call [ get sepParts, at join, call '' ]
        set [ get tableState ] firstRow false
      ]
    ] ]
    
    get tableParts, at push, call ''
    set [ get out ] value [ template '%0%1' [ get tableParts, at join, call [ get nl ] ] [ get nl ] ]
  ]
  
  get mdParts push, call [ get out value ]
] ]

# Join all parts
set markdown [ get mdParts, at join, call '' ]
# Write to file
set outputPath [ template '%0/documentation.md' [ get projectRoot ] ]
global fs writeFile, call [ get outputPath ] [ get markdown ] utf-8

log 'Done! Generated' [ get outputPath ]
