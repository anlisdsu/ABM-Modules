; Title: Geomorphology ABM
; Version 1.0
; Author: Li An
; Purpose: For education and demonstration purpose. With initial input from the paper "Feedbacks in human-landscape systems: Lessons from the Waldo 
; Canyon Fire of Colorado, USA" by Chin, An, Florsheim et al.

breed [segments segment]   ; Using this declaration, We set up a class of agents named segment and they are in a agentset named segments
                           ; These turtles (mobile agents--a jargon in Netlogo) are not used later in the code
globals [      ; Define a couple of global variables
  clock        ; To count time steps. Not used because of ticks  
  change-rate  ; Change rate of sediment thickness
]

patches-own [  ; Here we define a few attribute variables for patches
 stream?       ; A logic variable that takes either true or false
 elevation
 hardrock-elev
 sediment-thick
 patch-ID
]

segments-own [  ; Here we define a few attribute variables for "turtles" or agents (not used though)
 my-ID
 elev
]

to setup                 ; In Netlogo, a procedure begins with a to and ends with an end.
  clear-all
  set clock 0
  set change-rate 0.03   ; A hypothetical value for change rate for code test.
  setup-patches
  ;create-segments 10

  reset-ticks
end                      ; The "end" command ends the procedure

to setup-patches   ;This procedure sets up the original landscape at time 0
  ask patches [
   
    set stream? false   ;By default, the cells are not stream but dryland
    set pcolor grey     ;Grey stands for all dryland
    set hardrock-elev 300 
    set sediment-thick 0 
    set  patch-ID 10000    ; All non-stream patches are assigned a high patch-ID of 10000.
    
    if (pxcor = 2 and pycor = 3) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.0 
      set sediment-thick 0.20
      set patch-ID 1       ; The segment or patch at the lowest elevation or downstream
     ]
    if (pxcor = 2 and pycor = 4) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.1 
      set sediment-thick 0.20 
      set patch-ID 2
     ] 
    if (pxcor = 2 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.2 
      set sediment-thick 0.21 
      set patch-ID 3
     ]
    if (pxcor = 3 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.3 
      set sediment-thick 0.21 
      set patch-ID 4
      ]
    if (pxcor = 4 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.4 
      set sediment-thick 0.21 
      set patch-ID 5
     ]   
    if (pxcor = 4 and pycor = 6) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.5 
      set sediment-thick 0.21 
      set patch-ID 6
     ] 
    if (pxcor = 5 and pycor = 6) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.6 
      set sediment-thick 0.22 
      set patch-ID 7
     ]  
    if (pxcor = 5 and pycor = 7) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.7 
      set sediment-thick 0.22 
      set patch-ID 8
     ]
    if (pxcor = 5 and pycor = 8) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.8
      set sediment-thick 0.22 
      set patch-ID 9
     ]
    if (pxcor = 6 and pycor = 8) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.8 
      set sediment-thick 0.23 
      set patch-ID 10
     ]    
    set elevation hardrock-elev + sediment-thick
  ]   
  
end


to sediment-change           ; A procedure that sets the change rate

  ask patches with [pcolor = blue] [
    set sediment-thick sediment-thick * (1 + change-rate)
    set elevation hardrock-elev + sediment-thick

  ]
  
end

to do-plots                  ; A procedure that plots data

  set-current-plot "Plot-it"
  clear-plot
  
  let List_of_segments []    ; Prepare a blank list for later use
  let List_of_elev []        ; The same as above. 
 
  ask patches with [stream? = true] [   ; Put all stream patches into the list named List_of_segments

     set List_of_segments  lput patch-ID List_of_segments  
     set List_of_elev lput elevation List_of_elev
  ] 
  ;show sort List_of_segments     ; Remove the semicolon to activate the command (more often used in testing code)
  ;show List_of_segments
  ;show List_of_elev

  foreach sort List_of_segments [ ; This loop goes thru all elements in the list in an ascending order (b/c we sort the list first)
    ask patches with [patch-ID = ?] [  ; Why sort: to plot the elevations in order. Otherwise the plot goes back and forth (messy!)
      plotxy patch-ID elevation
    ]
  ]
  
  let mymean mean List_of_elev    ; Here we create a new variable named mymean, and assign the mean of the list to it
  ;show myMean  
    
End 

to go                             ; The procedure named go is fundamental in Netlogo. It is the major procedure that controls all processes.
  if ticks >= 200 [ stop ]        ; Keep the go procedure as simple as possible (even though you can put more things in it)
  set clock (clock + 1)
  sediment-change
  do-plots
  ;show clock                     ; In our setting, clock begins with 1 but ticks always 0. They both count time steps
  show ticks
  tick                            ; This command (actually a primitive or Netlogo built-in command) advances the tick counter by 1, i.e., 
end                               ; let the system move forward one time step. Other primitives: die, hatch, forward
@#$#@#$#@
GRAPHICS-WINDOW
185
8
650
494
17
17
13.0
1
10
1
1
1
0
0
0
1
-17
17
-17
17
1
1
1
ticks
30.0

BUTTON
66
81
129
114
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
250
153
283
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
789
369
1091
558
Elevation of riverbed segments
Segment IDs
Elevation of patches
0.0
10.0
0.0
120.0
true
false
"" "clear-plot"
PENS
"1" 1.0 1 -5295495 true "" "plotxy 1 mean [elevation] of patches with [patch-ID = 1]"
"2" 1.0 1 -7500403 true "" "plotxy 2 mean [elevation] of patches with [patch-ID = 2]"
"3" 1.0 1 -2674135 true "" "plotxy 3 mean [elevation] of patches with [patch-ID = 3]"
"4" 1.0 1 -4528153 true "" "plotxy 4 mean [elevation] of patches with [patch-ID = 4]"
"5" 1.0 1 -6459832 true "" "plotxy 5 mean [elevation] of patches with [patch-ID = 5]"
"6" 1.0 1 -1184463 true "" "plotxy 6 mean [elevation] of patches with [patch-ID = 6]"
"7" 1.0 1 -10899396 true "" "plotxy 7 mean [elevation] of patches with [patch-ID = 7]"
"8" 1.0 1 -10470017 true "" "plotxy 8 mean [elevation] of patches with [patch-ID = 8]"
"9" 1.0 1 -13740902 true "" "plotxy 9 mean [elevation] of patches with [patch-ID = 9]"
"10" 1.0 1 -16644859 true "" "plotxy 10 mean [elevation] of patches with [patch-ID = 10]"

PLOT
788
134
1091
339
Plot-it
Segments
Elevation
0.0
14.0
0.0
120.0
true
false
"clear-plot" ""
PENS
"default" 1.0 0 -16777216 true "" "Plot-it"

PLOT
190
558
461
764
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [elevation] of patches with [stream? = true]"

@#$#@#$#@
## WHAT IS IT?

A simple agent-based model to simualte river change profile change (here sediment change). Here we siulate only a small part of a river (ten segments), and each segment is an agent or object.

For each segment: (profile) elevation = hardrock-elev +  sediment-thick

where hardrock-elev (hardrock or bedrock elevation) is constant for the time being; only sediment-thick (the thickness of sediment) is subject to change if river flow is large enough.

## HOW IT WORKS

Here some hypothetical hardrock-elev and sediment-thick data are used (directly built in the code; no import from external files for now). The sediment change rate (change-rate) per day (time step or tick) is set as constant.

## HOW TO USE IT

Go to the Interface tab, click the setup button to set up the world (landscape) first; then click Run to run the model.

## THINGS TO NOTICE

The code is designed for step-by-step learning of building an ABM in Netlogo. So we are not concerned about advanced ABM features. By  reading the code, the learner may know what a primary ABM in Netlogo may look like, how to define various variables, procedures, agents, etc. 

## THINGS TO TRY

Run the model and see 1) how the average profile elevation of all 10 segments may change over time; 2) what the profile elevation of indidual segments (#1 to #10) is at each discreate time; 3) Go to the Code tab and change the value of change-rate from 0.03 to other values and run to the model and see the dynamics of profile elevations.

## EXTENDING THE MODEL

There are a number of later versions that build on this simple model, which keeps adding new features or functinalities.

## NETLOGO FEATURES

In the do-plots procedure, see how elevation is plotted against segment #s--first sort the ten elements by Patch-ID, and plot the elevation against the patch-ID. Why saying this: Netlogo is easy and straightforward to plot something against time, not other variables.

## RELATED MODELS

N/A

## CREDITS AND REFERENCES

The paper "Feedbacks in human-landscape systems:  lessons from the Waldo Canyon Fire of Colorado, USA" (Anne Chin, Li An, Joan Florsheim, Laura Laurencio, Richard Marston, Anna Parker, Gregory Simon, Ellen Wohl) stimulated the development of this education purpose model.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
