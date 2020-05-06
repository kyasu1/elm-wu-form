module Preview exposing (view)

import FormUtils
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
        [ h1 [ class "p-2 font-bold text-lg text-center" ] [ text "Western Union Transaction Form / ウェスタンユニオン送金メモ" ]
        , div [ class "space-y-2" ] <|
            div [ class "border p-4" ]
                [ h2 [ class "font-bold pb-4" ] [ text "Your Information お客様情報" ]
                , Customer.view customer
                ]
                :: Transaction.viewPreview zone ts
        , div [ class "print:hidden"]
            [ div [ class "pt-2" ]
                [ div [ class "flex justify-center sm:justify-end" ]
                    [ FormUtils.cancelButton close "Close"
                    , FormUtils.okButton print "Print"
                    ]
                ]
            ]
        ]
