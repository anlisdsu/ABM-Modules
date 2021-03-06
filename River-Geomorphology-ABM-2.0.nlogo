; Title: Geomorphology ABM
; Version 2.0
; Author: Li An
; Purpose: For education and demonstration purpose. With initial input from the paper "Feedbacks in human-landscape systems: Lessons from the Waldo 
; Canyon Fire of Colorado, USA" by Chin, An, Florsheim et al.

; 1) Major progress at version 2.0: new rules are made known based on input from Dr. Chin
;    (Copy and paste the rule from her email). Specifically, a new function sediment-change-in-order
;    was added to the code.
; 2) Also the critical dates (07-13-2013, 08-09-2013, 09-11,12,13,14-2014 all the way to 08-09-2014) 
;    are used in date calculation in the flow-change function, 
;    
breed [segments segment]

globals [
  clock          ; A clock for time  measurement (not necessary. tick does the same thing) 
  change-rate    ;The change rate of sediment thickness, which is a function of flow.
  
  flow           ; This variable controls the flow level in the stream
  storm?         ; A logic variable that controls whether there is a storm on a day (tick)
  storm-duration ; How long the storm has lasted, which is a number between 1 and 96 units (one 
                 ; unit is 15 minutes  
  available-thick 
]

patches-own [    ; See comments in v1.0
 stream? 
 elevation
 hardrock-elev
 sediment-thick
 patch-ID
]

segments-own [   ; See comments in v1.0
 my-ID
 elev
]

to setup
  clear-all
  set clock 0
  set storm? false     ; By default it does not have a storm
  set flow 40          ; This could be any number less than 65 cubic feet per second (cfs) for our simulation purpose 
  set storm-duration 0 ; The default is no storm, therefore storm duration is set at zero. This controls how much sediment is romoved during storm
  set change-rate 0    ; The change rate is zero unless there is a storm and the flow raises to 65 or above.
  setup-patches        ; This function (?) is defined below.
  reset-ticks
end

to setup-patches   ;This step sets up the original landscape at time 0
  ask patches [
   
    set stream? false   ;By default, the cells are not stream but dryland
    set pcolor grey     ;Grey stands for all dryland
    set hardrock-elev 300 
    set sediment-thick 0 
    set  patch-ID 10000    
    
    if (pxcor = 2 and pycor = 3) [set stream? true  ; Note all elevation and thickness values below are hypothetical for code testing purpose
      set pcolor blue 
      set hardrock-elev 90.0 
      set sediment-thick 0.20
      set patch-ID 10               ; This used to be 1. To make the upper patches with a lower patch-ID, I did a swap
     ]
    if (pxcor = 2 and pycor = 4) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.1 
      set sediment-thick 0.20 
      set patch-ID 9
     ] 
    if (pxcor = 2 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.2 
      set sediment-thick 0.21 
      set patch-ID 8
     ]
    if (pxcor = 3 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.3 
      set sediment-thick 0.21 
      set patch-ID 7
      ]
    if (pxcor = 4 and pycor = 5) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.4 
      set sediment-thick 0.21 
      set patch-ID 6
     ]   
    if (pxcor = 4 and pycor = 6) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.5 
      set sediment-thick 0.21 
      set patch-ID 5
     ] 
    if (pxcor = 5 and pycor = 6) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.6 
      set sediment-thick 0.22 
      set patch-ID 4
     ]  
    if (pxcor = 5 and pycor = 7) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.7 
      set sediment-thick 0.22 
      set patch-ID 3
     ]
    if (pxcor = 5 and pycor = 8) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.8
      set sediment-thick 0.22 
      set patch-ID 2
     ]
    if (pxcor = 6 and pycor = 8) [set stream? true 
      set pcolor blue 
      set hardrock-elev 90.8 
      set sediment-thick 0.23 
      set patch-ID 1
     ]    
    set elevation hardrock-elev + sediment-thick
  ]   
  
end

to flow-change
  ifelse (ticks = 27 or (ticks >= 59 and ticks <= 62)) [  ; Flow change reflects whether it rains & the river flow rises on some days
    set flow 70      ; Days 27 and 59, 60, 61, andn 62 are days with storms (changed to 27, 60, 61, 62, and 63 in v5.3. 
    set storm? true  ; The number 70 is just one between 65 and 310
  ]
  [ set flow 40
    set storm? false
  ]
  
  ifelse (storm? = false)   ; The above ifelse clause sets what days would be storm days
  [set storm-duration 0]    ; On days without storms, the storm duration is zero
  [                         ; On days with a storm, the storm duration is set to different numbers according to Anne's data
    if (ticks = 27 ) [
      set storm-duration 3 
    ]    

    if (ticks = 59 ) [
      set storm-duration 2 
    ]  
    
    if (ticks >= 60 and ticks <= 62 ) [
      set storm-duration 5 ; Used to be 96 according to Anne's rules (version 1)--see the Info tab
    ]
  ]
  ;show ticks
  ;show clock
  ;show flow
   
end

;Alternative 1: When storm comes, the sediments in all segments are removed to the same extent--no order or sequence
to sediment-change-no-order

  ask patches with [pcolor = blue] [
    ifelse (storm? = true)[
      set change-rate -0.113 * storm-duration 
    ]
    [set change-rate 0]
    
    ifelse (sediment-thick * (1 + change-rate) > 0) [
      set sediment-thick sediment-thick * (1 + change-rate)
    ]
    [set sediment-thick 0]
    
    
    set elevation hardrock-elev + sediment-thick
    ;show sediment-thick
    ;show elevation
  ] 
end

; Alternative 2: When storm comes, the sediments in upstream segments are first removed:

to sediment-change-in-order
  
  let List_of_segments []                  ; Create a list as a container of stream patches
  
  ask patches with [pcolor = blue] [       ; Sediment change only happen on stream patches (blue)   
    
    set List_of_segments  lput patch-ID List_of_segments   ; Put all stream patches into the above list
    ifelse (storm? = true)[                ; Only for days with storm
      set change-rate -0.113 * storm-duration ; A negative number for sediment change per day
    ]
    [set change-rate 0]                    ; For days without storm, the change rate is zero
    
  ]  ; The end of ask patches clause
  
  set available-thick 0.113 * storm-duration  ; This is the total amount of sediment (thickness) that is to be removed
  
  foreach sort List_of_segments [          ; Why sort: according to the rule (see Info table), the segments upstream will be 
                                           ; remvoed first; this sediment removal continues to the next segment till the amount
    ask patches with [patch-ID = ?] [      ; set in the variable available-thick is reached
      
      ifelse (available-thick > sediment-thick) [
        set available-thick available-thick - sediment-thick
        set sediment-thick 0
      ]
      [
        set sediment-thick sediment-thick - available-thick
        set available-thick 0
      ]
           
      set elevation hardrock-elev + sediment-thick  ; Finally, profile elevation is the sum of bedrock elevation 
      ;show sediment-thick                          ; No need to print them except for code debugging         
      ;show available-thick        
    ]   ; End of ask patches
  ] ; End of foreach loop
  
end

to do-plots                                ; No new comments. See comments in v1.0

  set-current-plot "Plot-it"
  clear-plot
  
  let List_of_segments []
  let List_of_elev []
 
  ask patches with [stream? = true] [

     set List_of_segments  lput patch-ID List_of_segments  
     set List_of_elev lput elevation List_of_elev
  ] 
  ;show sort List_of_segments   ; No need to print them except for code debugging 
  ;show sort List_of_segments
  ;show List_of_elev

  foreach sort List_of_segments [
    ask patches with [patch-ID = ?] [
      plotxy patch-ID elevation
    ]
  ]
  
  let mymean mean List_of_elev 
  ;show myMean  
  
End 

to go                                      ; No new comments. See comments in v1.0
  if ticks >= 80 [ stop ]  
  set clock (clock + 1)
  flow-change
  ;sediment-change-no-order
  sediment-change-in-order      ; This one is the default.
  ;plot-average-elevation-over-time
  do-plots
  show ticks
  ;show storm-duration
  tick
end
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
Rules for model for sediment erosion (Version 1):
1.	If flow <65 cfs (cubic feet per second), no net change in sediment thickness (surface elevation).

2.	If 65 cfs < flow < 311cfs:

For each 15 min interval during the day that 65 cfs < flow < 311 cfs, sediment thickness decreases by 0.113m from the most upstream segment.  [Downstream segments are not yet affected because the sediments that erode from the upstream segment will replace any downstream losses.]

On 9 Aug 2013, 65 cfs < flow < 311 cfs during three 15-min intervals, therefore sediment thickness decreases by 0.113 m x 3 = 0.339 m.

On 11 Sept 2013, 65 cfs < flow < 311 cfs during two 15-min intervals, therefore sediment thickness decreases by 0.113 m x 2 = 0.226 m.

On 12 Sept 2013, 65 cfs < flow < 311 cfs during 96 15-min intervals, therefore sediment thickness decreases by 0.113 m x 96 = 10.848 m.   [After sediment thickness decreases to 0 in first segment, decreasing sediment thickness continues in next segment downstream).

On 13 Sept 2013, 65 cfs < flow < 311 cfs during 96 15-min intervals, therefore sediment thickness decreases by 0.113 m x 96 = 10.848 m.   [After sediment thickness decreases to 0 in first segment, decreasing sediment thickness continues in next segment downstream).

On 14 Sept 2013, 65 cfs < flow < 311 cfs during 96 15-min intervals, therefore sediment thickness decreases by 0.113 m x 96 = 10.848 m.   [After sediment thickness decreases to 0 in first segment, decreasing sediment thickness continues in next segment downstream).


3.	 If flow >311 cfs, sediment thickness decreases by 0.230m from the most upstream segment.  
This situation does not occur during study period.

4.	Once the first segment erodes to bedrock (i.e., sediment thickness decreases to 0), the next downstream segment will begin to decrease in sediment thickness (erode) following the rules above.  This process will result in the channel eroding in a downstream progression.
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
