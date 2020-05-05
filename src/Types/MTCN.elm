module Types.MTCN exposing (..)

import Json.Decode as D
import Json.Encode as E


type MTCN
    = MTCN String


toString : MTCN -> String
toString (MTCN s) =
    s


fromString : String -> MTCN
fromString s =
    MTCN s


encode : MTCN -> E.Value
encode =
    E.string << toString


decoder : D.Decoder MTCN
decoder =
    D.string
        |> D.map MTCN
