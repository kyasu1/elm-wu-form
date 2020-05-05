module Icons exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (class, d, fill, height, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox, width)



{-
   https://github.com/refactoringui/heroicons

   https://heroicons.dev/
-}


trash : String -> Svg msg
trash c =
    svg [ class c, fill "none", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", stroke "currentColor", viewBox "0 0 24 24" ]
        [ path [ d "M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" ] []
        ]


pencil : String -> Svg msg
pencil c =
    svg [ class c, fill "none", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", stroke "currentColor", viewBox "0 0 24 24" ]
        [ path [ d "M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" ]
            []
        ]


printer : String -> Svg msg
printer c =
    svg [ class c, fill "none", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", stroke "currentColor", viewBox "0 0 24 24" ]
        [ path [ d "M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" ] []
        ]


plus : String -> Svg msg
plus c =
    svg [ class c, fill "none", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", stroke "currentColor", viewBox "0 0 24 24" ]
        [ path [ d "M12 4v16m8-8H4" ] []
        ]


exclamation : String -> Svg msg
exclamation c =
    svg [ class c, fill "none", stroke "currentColor", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", viewBox "0 0 24 24" ]
        [ path [ d "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" ]
            []
        ]


x : String -> Svg msg
x c =
    svg [ class c, fill "none", stroke "currentColor", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", viewBox "0 0 24 24" ]
        [ path [ d "M6 18L18 6M6 6l12 12" ]
            []
        ]
