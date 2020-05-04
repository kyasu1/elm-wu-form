module Icons exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (class, d, fill, height, stroke, strokeLinecap, strokeLinejoin, strokeWidth, viewBox, width)


mdTrash : Svg msg
mdTrash =
    svg [ width "24", height "24", viewBox "0 0 24 24", fill "none" ]
        [ path
            [ d "M19 7L18.1327 19.1425C18.0579 20.1891 17.187 21 16.1378 21H7.86224C6.81296 21 5.94208 20.1891 5.86732 19.1425L5 7M10 11V17M14 11V17M15 7V4C15 3.44772 14.5523 3 14 3H10C9.44772 3 9 3.44772 9 4V7M4 7H20"
            , stroke "#4A5568"
            , strokeWidth "2"
            , strokeLinecap "round"
            , strokeLinejoin "round"
            ]
            []
        ]


trash : String -> Svg msg
trash c =
    svg [ class c, fill "none", strokeLinecap "round", strokeLinejoin "round", strokeWidth "2", stroke "currentColor", viewBox "0 0 24 24" ]
        [ path [ d "M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" ] []
        ]


mdX : Svg msg
mdX =
    svg [ width "24", height "24", viewBox "0 0 24 24", fill "none" ]
        [ path [ d "M6 18L18 6M6 6L18 18", stroke "#4A5568", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round" ] []
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
