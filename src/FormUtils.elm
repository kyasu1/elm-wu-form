module FormUtils exposing
    ( Error
    , cancelButton
    , customAlpha
    , dangerButton
    , field
    , formatFloatPrice
    , fromString
    , okButton
    , optional
    , required
    , toString
    )

import Form.Decoder as FD
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Round



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


formatFloatPrice : Float -> String
formatFloatPrice price =
    case Round.round 4 price |> String.split "." of
        d :: "0000" :: _ ->
            formatPrice d

        d :: f :: _ ->
            formatPrice d ++ "." ++ f

        _ ->
            ""


formatPrice : String -> String
formatPrice price =
    price
        |> String.toList
        |> List.reverse
        |> formatPriceHelper []
        |> List.reverse
        |> String.join ","


formatPriceHelper : List String -> List Char -> List String
formatPriceHelper sum list =
    case list of
        [] ->
            sum

        _ ->
            (List.take 3 list |> List.reverse |> String.fromList) :: formatPriceHelper sum (List.drop 3 list)



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
                [ class <| "border sm:ml-2 px-2 py-1 w-full" ++ borderClass
                , value v
                , onInput (\s -> u <| String.trim s)
                , name n
                ]
                []
            , span [ class "inline-block py-1 px-2 text-sm text-red-500" ] [ text (Maybe.withDefault "\u{3000}" errorText) ]
            ]
        ]



--


cancelButton : msg -> Html msg -> Html msg
cancelButton msg title =
    span [ class "inline-flex rounded-md shadow-sm" ]
        [ button
            [ class "py-1 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out"
            , type_ "button"
            , onClick msg
            ]
            [ title ]
        ]


okButton : msg -> Html msg -> Html msg
okButton msg title =
    span [ class "ml-3 inline-flex rounded-md shadow-sm" ]
        [ button
            [ class "inline-flex justify-center py-1 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out"
            , type_ "submit"
            , onClick msg
            ]
            [ title ]
        ]


dangerButton : msg -> Html msg -> Html msg
dangerButton msg title =
    span [ class "ml-3 inline-flex rounded-md shadow-sm" ]
        [ button
            [ class "inline-flex justify-center py-1 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-red-600 hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red active:bg-red-700 transition duration-150 ease-in-out"
            , type_ "submit"
            , onClick msg
            ]
            [ title ]
        ]
