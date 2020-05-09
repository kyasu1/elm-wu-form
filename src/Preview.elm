module Preview exposing (view)

import FormUtils
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Icons
import Time
import Types.Customer as Customer exposing (Customer)
import Types.Transaction as Transaction exposing (Transaction)


view :
    { customer : Customer
    , ts : List Transaction
    , zone : Time.Zone
    , close : msg
    , print : msg
    }
    -> Html msg
view { customer, ts, close, print, zone } =
    div [ class "sheet padding-10mm mx-auto" ]
        [ h1 [ class "p-2 mb-2 font-bold text-lg text-center" ]
            [ img [ src "/logo.wu.big.svg", class "inline w-40 bg-black mr-4" ] []
            , span [ class "mt-1" ] [ text "Transaction Form / 送金メモ" ]
            ]
        , div [ class "space-y-2" ] <|
            div [ class "border p-4" ]
                [ h2 [ class "font-bold pb-4" ] [ text "Your Information お客様情報" ]
                , Customer.view customer
                ]
                :: Transaction.viewPreview zone ts
        , div [ class "print:hidden" ]
            [ div [ class "pt-2" ]
                [ div [ class "flex justify-center sm:justify-end" ]
                    [ FormUtils.cancelButton close <| span [ class "flex items-center" ] [ Icons.x "w-4 h-4", span [ class "ml-2" ] [ text "Close" ] ]
                    , FormUtils.okButton print <| span [ class "flex items-center" ] [ Icons.printer "w-4 h-4", span [ class "ml-2" ] [ text "Print" ] ]
                    ]
                ]
            ]
        , div [ class "hidden print:block text-sm leading-6 text-gray-900 text-center p-4" ]
            [ p [] [ text "Please bring this form to your agent. この用紙を代理店までお持ちください" ]
            , p [] [ a [ href "https://www.officeiko.co.jp/", target "_blank" ] [ text "© 2020 Office IKO Co. All rights reserved." ] ]
            ]
        ]
