module Types exposing
    ( Customer
    , SendToRecord
    , Transaction
    , customerDecoder
    , encodeCustomer
    , encodeTransaction
    , removeTransaction
    , sendTo
    , transactionDecoder
    , viewPreviewTransaction
    , viewTransaction
    )

import Data.Occupation exposing (Occupation)
import Data.PayoutCountry as PayoutCountry
import Data.Purpose exposing (Purpose)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Icons
import Json.Decode as D
import Json.Encode as E
import Json.Encode.Extra as E
import Time exposing (Posix)
import Time.Extra as Time
import Types.MyNumber exposing (MyNumber)
import Types.Name exposing (Name)
import Ulid exposing (Ulid)


type alias Customer =
    { name : Name
    , tel : String
    , myNumber : Maybe MyNumber
    , occupation : Occupation
    , nationality : String
    }


encodeCustomer : Customer -> E.Value
encodeCustomer f =
    E.object
        [ ( "name", Types.Name.encode f.name )
        , ( "tel", E.string f.tel )
        , ( "myNumber", E.maybe Types.MyNumber.encode f.myNumber )
        , ( "occupation", Data.Occupation.encode f.occupation )
        , ( "nationality", E.string f.nationality )
        ]


customerDecoder : D.Decoder Customer
customerDecoder =
    D.map5 Customer
        (D.field "name" Types.Name.decoder)
        (D.field "tel" D.string)
        (D.field "myNumber" (D.maybe Types.MyNumber.decoder))
        (D.field "occupation" Data.Occupation.decoder)
        (D.field "nationality" D.string)



--
--


type MTCN
    = MTCN String


mtcnToString : MTCN -> String
mtcnToString (MTCN s) =
    s


mtcnDecoder : D.Decoder MTCN
mtcnDecoder =
    D.string
        |> D.map MTCN



--


type Transaction
    = SendTo SendToRecord
    | RecvFrom RecvFromRecord


removeTransaction : Ulid -> List Transaction -> List Transaction
removeTransaction ulid ts =
    List.filter
        (\t ->
            case t of
                SendTo r ->
                    r.ulid /= ulid

                RecvFrom r ->
                    r.ulid /= ulid
        )
        ts


sendTo : SendToRecord -> Transaction
sendTo =
    SendTo


type alias SendToRecord =
    { ulid : Ulid
    , posix : Posix
    , name : Name
    , amount : Float
    , countryCode : PayoutCountry.Code
    , purpose : Purpose
    }


type alias RecvFromRecord =
    { ulid : Ulid
    , posix : Posix
    , name : Name
    , amount : Float
    , purpose : Purpose
    , mtcn : MTCN
    }


encodeTransaction : Transaction -> E.Value
encodeTransaction t =
    case t of
        SendTo r ->
            E.object
                [ ( "type", E.string "sendTo" )
                , ( "record", encodeSendToRecord r )
                ]

        RecvFrom r ->
            E.object
                [ ( "type", E.string "recvFrom" )
                , ( "record", encodeRecvFromRecord r )
                ]


encodeSendToRecord : SendToRecord -> E.Value
encodeSendToRecord r =
    E.object
        [ ( "ulid", Ulid.encode r.ulid )
        , ( "posix", E.int <| Time.posixToMillis r.posix )
        , ( "name", Types.Name.encode r.name )
        , ( "amount", E.float r.amount )
        , ( "code", E.string <| PayoutCountry.toString r.countryCode )
        , ( "purpose", E.string <| Data.Purpose.toString r.purpose )
        ]


encodeRecvFromRecord : RecvFromRecord -> E.Value
encodeRecvFromRecord r =
    E.object
        [ ( "ulid", Ulid.encode r.ulid )
        , ( "posix", E.int <| Time.posixToMillis r.posix )
        , ( "name", Types.Name.encode r.name )
        , ( "amount", E.float r.amount )
        , ( "purpose", E.string <| Data.Purpose.toString r.purpose )
        , ( "mtcn", E.string <| mtcnToString r.mtcn )
        ]


transactionDecoder : D.Decoder Transaction
transactionDecoder =
    D.field "type" D.string
        |> D.andThen
            (\t ->
                case t of
                    "sendTo" ->
                        D.field "record" sendToRecordDecoder |> D.map SendTo

                    "recvFrom" ->
                        D.field "record" recvFromRecordDecoder |> D.map RecvFrom

                    _ ->
                        D.fail "Invalid record type"
            )


sendToRecordDecoder : D.Decoder SendToRecord
sendToRecordDecoder =
    D.map6 SendToRecord
        (D.field "ulid" Ulid.decode)
        (D.field "posix" D.int |> D.map Time.millisToPosix)
        (D.field "name" Types.Name.decoder)
        (D.field "amount" D.float)
        (D.field "code" PayoutCountry.decoder)
        (D.field "purpose" Data.Purpose.decoder)


recvFromRecordDecoder : D.Decoder RecvFromRecord
recvFromRecordDecoder =
    D.map6 RecvFromRecord
        (D.field "ulid" Ulid.decode)
        (D.field "posix" D.int |> D.map Time.millisToPosix)
        (D.field "name" Types.Name.decoder)
        (D.field "amount" D.float)
        (D.field "purpose" Data.Purpose.decoder)
        (D.field "mtcn" mtcnDecoder)



--


viewTransaction :
    { zone : Time.Zone
    , edit : Transaction -> msg
    , remove : Ulid -> msg
    }
    -> Transaction
    -> Html msg
viewTransaction { zone, edit, remove } t =
    case t of
        SendTo r ->
            div [ class "border p-4 hover:bg-blue-100", class "cursor-pointer" ]
                [ div [ class "flex justify-end space-x-2" ]
                    [ a
                        [ onClick <| edit t
                        , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-blue-500 hover:bg-blue-300"
                        ]
                        [ Icons.pencil "w-4 h-4 text-white group-hover:text-gray-500"
                        ]
                    , a
                        [ onClick <| remove r.ulid
                        , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-red-500 hover:bg-red-300"
                        ]
                        [ Icons.trash "w-4 h-4 text-white group-hover:text-gray-500"
                        ]
                    ]
                , viewSendTo zone r True
                ]

        RecvFrom _ ->
            text ""


viewPreviewTransaction : Time.Zone -> Transaction -> Html msg
viewPreviewTransaction zone t =
    case t of
        SendTo r ->
            div [ class "border p-4" ]
                [ h2 [ class "font-bold pb-4" ] [ text "Recipient Information 受取人様情報" ]
                , viewSendTo zone r False
                ]

        RecvFrom _ ->
            text ""


viewSendTo : Time.Zone -> SendToRecord -> Bool -> Html msg
viewSendTo zone r showTime =
    div [ class "grid grid-cols-1 print:grid-col-3 sm:grid-cols-3 col-gap-4 row-gap-4" ]
        [ if showTime then
            div [ class "col-span-3" ]
                [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Last time used（最後に使った日時）" ]
                , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| posixToDateTime zone r.posix ]
                ]

          else
            text ""
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "First Name（名）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text r.name.firstName ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Middle Name（ミドルネーム）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Maybe.withDefault "\u{3000}" r.name.middleName ]
            ]
        , div [ class "" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Last Name（姓）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text r.name.lastName ]
            ]
        , div []
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Amount to be sent（送金額）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| String.fromFloat r.amount ]
            ]
        , div []
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Currency（通貨）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| PayoutCountry.lookup r.countryCode ]
            ]
        , div []
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Purpose（送金目的）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Data.Purpose.toString r.purpose ]
            ]
        ]


posixToDateTime : Time.Zone -> Posix -> String
posixToDateTime zone posix =
    Time.posixToParts zone posix
        |> (\parts ->
                [ String.fromInt parts.year
                , "/"
                , padZero2 <| toNumericMonth parts.month
                , "/"
                , padZero2 <| String.fromInt parts.day
                , " "
                , padZero2 <| String.fromInt parts.hour
                , ":"
                , padZero2 <| String.fromInt parts.minute
                , ":"
                , padZero2 <| String.fromInt parts.second
                , "（"
                , toJapaneseWeekday <| Time.toWeekday zone posix
                , "）"
                ]
                    |> String.concat
           )


padZero2 : String -> String
padZero2 =
    String.padLeft 2 '0'


toNumericMonth : Time.Month -> String
toNumericMonth month =
    case month of
        Time.Jan ->
            "01"

        Time.Feb ->
            "02"

        Time.Mar ->
            "03"

        Time.Apr ->
            "04"

        Time.May ->
            "05"

        Time.Jun ->
            "06"

        Time.Jul ->
            "07"

        Time.Aug ->
            "08"

        Time.Sep ->
            "09"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


toJapaneseWeekday : Time.Weekday -> String
toJapaneseWeekday weekday =
    case weekday of
        Time.Mon ->
            "月"

        Time.Tue ->
            "火"

        Time.Wed ->
            "水"

        Time.Thu ->
            "木"

        Time.Fri ->
            "金"

        Time.Sat ->
            "土"

        Time.Sun ->
            "日"
