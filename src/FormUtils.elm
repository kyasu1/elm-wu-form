module FormUtils exposing (Error, customAlpha, field, fromString, optional, required, toString)

import Form.Decoder as FD
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



--


type Error
    = Error String


fromString : String -> Error
fromString =
    Error


toString : Error -> String
toString (Error s) =
    s



--


optional : FD.Decoder String err a -> FD.Decoder String err (Maybe a)
optional d =
    FD.with <|
        \s ->
            case s of
                "" ->
                    FD.always Nothing

                _ ->
                    FD.map Just d


required : FD.Validator String Error
required =
    FD.minLength (Error "入力してください") 1


customAlpha : FD.Validator String Error
customAlpha =
    FD.custom <|
        \s ->
            if String.filter (\c -> Char.isAlpha c |> not) s /= "" then
                Err [ Error "アルファベットのみです" ]

            else
                Ok ()



--


field :
    { v : String
    , l : String
    , u : String -> msg
    , d : FD.Decoder String Error a
    , n : String
    , submitted : Bool
    }
    -> Html msg
field { v, l, u, d, n, submitted } =
    let
        errorText =
            if submitted then
                case FD.run d v of
                    Err ((Error e) :: _) ->
                        Just e

                    _ ->
                        Nothing

            else
                Nothing

        borderClass =
            Maybe.map (\_ -> " border-red-500") errorText |> Maybe.withDefault ""
    in
    label [ class "block px-2 py-2 w-full" ]
        [ div [ class "text-xs px-2" ] [ text l ]
        , div [ class "relative" ]
            [ input
                [ class <| "border ml-2 px-2 py-1 w-full" ++ borderClass
                , value v
                , onInput (\s -> u <| String.trim s)
                , name n
                ]
                []
            , span [ class "inline-block py-1 px-2 text-sm text-red-500" ] [ text (Maybe.withDefault "\u{3000}" errorText) ]
            ]
        ]
