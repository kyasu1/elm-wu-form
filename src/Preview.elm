module Preview exposing (view)

import Data.Occupation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Time
import Types exposing (Customer, Transaction)
import Types.MyNumber


view :
    { customer : Customer
    , ts : List Transaction
    , zone : Time.Zone
    , close : msg
    , print : msg
    }
    -> Html msg
view { customer, ts, close, print, zone } =
    div [ class "sheet padding-10mm" ]
        [ h1 [ class "p-2 font-bold text-lg text-center" ] [ text "Western Union Transaction Form / ウェスタンユニオン送金メモ" ]
        , div [ class "space-y-2" ] <|
            div [ class "border p-4" ]
                [ h2 [ class "font-bold pb-4" ] [ text "Your Information お客様情報" ]
                , viewCustomer customer
                ]
                :: List.map (Types.viewPreviewTransaction zone) ts
        , div [ class "flex" ]
            [ div [ class "print:hidden" ] [ button [ onClick close ] [ text "Close" ] ]
            , div [ class "print:hidden" ] [ button [ onClick print ] [ text "Print" ] ]
            ]
        ]


viewCustomer : Customer -> Html msg
viewCustomer c =
    div [ class "grid grid-cols-1 print:grid-cols-3 sm:grid-cols-3 col-gap-4 print:row-gap-4 row-gap-8" ]
        [ div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "First Name（名）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text c.name.firstName ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Middle Name（ミドルネーム）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Maybe.withDefault "\u{3000}" c.name.middleName ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Last Name（姓）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text c.name.lastName ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "My Number（マイナンバー）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Maybe.withDefault "\u{3000}" <| Maybe.map Types.MyNumber.toString c.myNumber ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Tel（電話番号）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text c.tel ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Nationality（国籍）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text c.nationality ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Occupation（職業）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Data.Occupation.lookup c.occupation ]
            ]
        ]
