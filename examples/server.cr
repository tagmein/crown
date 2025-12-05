set fs [ global import, call fs/promises ]
set http [ global import, call node:http ]

set port [ global process env PORT, default 4567 ]

set i [ function x [
 get fs readFile, call [ get x ]
 at toString, call utf-8
] ]

set handler [
 function request response [
  set respond [
   function status value [
    set [ get response ] statusCode [ get status ]
    get value, typeof, is object, true [
     get response end, call [
      global JSON stringify, call [ get value ]
     ]
    ]
    false [
     get response end, call [ get value ] 
    ]
   ]
  ]

  log [ get request method ] [ get request url ]

  try [
   # Routes
   get request url, pick [
    is /
    get respond, call 200 '<!doctype html>
<html>
<head>
 <title>Crown Example Server</title>
 <style>
  body {
   background-color: black;
  }
  body, a {
   color: white;
  }
 </style>
 <script src="./crown.js"></script>
</head>
<body>
 <h1>Crown Example Server</h1>
 <p><a href="/documentation">Crown documentation</a></p>
</body>
'
   ] [
    is /documentation
    get respond, call 200 '<!doctype html>
<html>
<head>
 <title>Crown Documentation</title>
 <style>
  body {
   background: black;
   color: #f0f0f0;
   padding: 0 20px;
   font-size: 18px;
   line-height: 1.65;
  }
  a {
   color: inherit;
   text-decoration: none;
   border-bottom: 1px solid;
  }
  pre {
   font-size: inherit;
   white-space: pre-wrap;
  }
 </style>
 <script src="./crown.js"></script>
</head>
<body>
 <h1>Crown Documentation</h1>
 <script>
  crown().runFile(\'./documentation.cr\')
   .catch(e => console.error(e))
 </script>
</body>
'
   ] [
    is /crown.js
    get respond, call 200 [
     get i, call crown, at split
     call '/* UNIFIED */ ', at 1
    ]
   ] [
    do [ at endsWith, call .cr ]
    get respond, call 200 [
     get i, call [
     template '.%0' [ get request url ]
    ] ]
   ] [
    true 
    get respond, call 404 [ object [ error 'Not Found' ] ]
   ]
  ] [
   get respond, call 500 [ object [ error [ current_error ] ] ]
  ]
 ]
]

set server [
 get http createServer, call [ get handler ]
]

get server listen, call [ get port ] [
 function [
  log server listening on port [ get port ]
 ]
]
