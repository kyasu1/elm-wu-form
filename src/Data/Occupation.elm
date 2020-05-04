module Data.Occupation exposing (Occupation, decoder, default, encode, lookup, toString, list)

import Json.Decode as D
import Json.Encode as E


type Occupation
    = Occupation String


default : Occupation
default =
    Occupation "Employee"


encode : Occupation -> E.Value
encode v =
    E.string <| toString v


toString : Occupation -> String
toString (Occupation s) =
    s


lookup : Occupation -> String
lookup v =
    List.filter (\( c, _ ) -> c == v) list
        |> List.head
        |> Maybe.map (\( _, l ) -> l)
        |> Maybe.withDefault ""


decoder : D.Decoder Occupation
decoder =
    D.string
        |> D.andThen
            (\s ->
                case List.filter (\( Occupation c, _ ) -> c == s) list |> List.head of
                    Just ( o, _ ) ->
                        D.succeed o

                    Nothing ->
                        D.fail ("Invalid Occupation: " ++ s)
            )


list : List ( Occupation, String )
list =
    [ ( Occupation "Employee", "Employee/会社員" )
    , ( Occupation "Unemployed", "Unemployed/休職中" )
    , ( Occupation "Retired", "Retired/定年退職者" )
    , ( Occupation "Student", "Student/学生" )
    , ( Occupation "Teacher", "Teacher/教職" )
    , ( Occupation "Housewife", "Housewife/主婦" )
    ]
