module Types.Customer exposing
    ( Customer
    , decoder
    , encode
    , view
    )

import Data.Occupation exposing (Occupation)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as D
import Json.Encode as E
import Json.Encode.Extra as E
import Types.MyNumber exposing (MyNumber)
import Types.Name exposing (Name)


type alias Customer =
    { name : Name
    , tel : String
    , myNumber : Maybe MyNumber
    , occupation : Occupation
    , nationality : String
    }


encode : Customer -> E.Value
encode f =
    E.object
        [ ( "name", Types.Name.encode f.name )
        , ( "tel", E.string f.tel )
        , ( "myNumber", E.maybe Types.MyNumber.encode f.myNumber )
        , ( "occupation", Data.Occupation.encode f.occupation )
        , ( "nationality", E.string f.nationality )
        ]


decoder : D.Decoder Customer
decoder =
    D.map5 Customer
        (D.field "name" Types.Name.decoder)
        (D.field "tel" D.string)
        (D.field "myNumber" (D.maybe Types.MyNumber.decoder))
        (D.field "occupation" Data.Occupation.decoder)
        (D.field "nationality" D.string)


view : Customer -> Html msg
view c =
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
        , div [ class "border text-xs leading-5 text-gray-900 p-1 rounded" ]
            [ p [] [ text "株式会社オフィスイコー" ]
            , p [] [ text "埼玉県越谷市七左町1-299-1" ]
            , p [] [ text "TEL 048-987-1020" ]
            ]
        , div [ class "border text-xs leading-5 text-gray-900 p-1 rounded" ]
            [ p [] [ text "IKO PAWNSHOP" ]
            , p [] [ text "1-299-1 SHICHIZA, KOSHIGAYA" ]
            , p [] [ text "SAITAMA" ]
            ]            
        ]
