module Data.Purpose exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as D


type Purpose
    = MigrantRemittance
    | MedicalFee
    | TravelExpenses
    | TuitionFee
    | LivingExpenses
    | Gift


default : Purpose
default =
    MigrantRemittance


toString : Purpose -> String
toString p =
    List.filterMap
        (\( v, l ) ->
            if v == p then
                Just l

            else
                Nothing
        )
        list
        |> List.head
        |> Maybe.withDefault ""


decoder : D.Decoder Purpose
decoder =
    D.string
        |> D.andThen
            (\s ->
                case List.filter (\( _, l ) -> l == s) list |> List.head of
                    Just ( v, _ ) ->
                        D.succeed v

                    Nothing ->
                        D.fail ("Invalid Purpose " ++ s)
            )


list : List ( Purpose, String )
list =
    [ ( MigrantRemittance, "Migrant Remittance（家族送金）" )
    , ( MedicalFee, "Medical Fee（医療費）" )
    , ( TravelExpenses, "Travel Expenses（旅行費）" )
    , ( TuitionFee, "Tuition Fee（学費）" )
    , ( LivingExpenses, "Living Expenses（生活費）" )
    , ( Gift, "Gift（贈与）" )
    ]


view : { f | purpose : Purpose } -> ({ f | purpose : Purpose } -> msg) -> Html msg
view f tagger =
    div []
        [ div [ class "text-xs px-2" ] [ text "Purpose/送金目的" ]
        , div [ class "flex flex-wrap space-x-1" ]
            (List.map
                (\( v, l ) ->
                    label
                        [ class "inline-flex justify-center items-center px-2 py-0.5 rounded text-xs font-medium leading-4 h-8 mb-2"
                        , if f.purpose == v then
                            class "bg-blue-100 text-blue-800"

                          else
                            class "bg-gray-100 text-gray-800 cursor-pointer hover:bg-blue-50"
                        ]
                        [ input
                            [ type_ "radio"
                            , name "purpose"
                            , value l
                            , onClick ({ f | purpose = v } |> tagger)
                            , class "opacity-0"
                            ]
                            []
                        , span [ class "-ml-2" ] [ text l ]
                        ]
                )
                list
            )
        ]
