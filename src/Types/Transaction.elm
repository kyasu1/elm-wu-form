module Types.Transaction exposing
    ( RecvFromRecord
    , SendToRecord
    , Transaction
    , decoder
    , encode
    , recvFrom
    , removeTransaction
    , sendTo
    , upsert
    , viewPreview
    , viewRecvFrom
    , viewSendTo
    )

import Data.PayoutCountry as PayoutCountry
import Data.Purpose exposing (Purpose)
import FormUtils
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Icons
import Json.Decode as D
import Json.Encode as E
import Time exposing (Posix)
import Time.Extra as Time
import Types.MTCN as MTCN exposing (MTCN)
import Types.Name exposing (Name)
import Ulid exposing (Ulid)



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


unwrapUlid : Transaction -> Ulid
unwrapUlid t =
    case t of
        SendTo r ->
            r.ulid

        RecvFrom r ->
            r.ulid


upsert : Transaction -> List Transaction -> List Transaction
upsert t ts =
    case List.filter (\t_ -> unwrapUlid t == unwrapUlid t_) ts of
        [] ->
            t :: ts

        _ ->
            List.map
                (\t_ ->
                    if unwrapUlid t == unwrapUlid t_ then
                        t

                    else
                        t_
                )
                ts


sendTo : SendToRecord -> Transaction
sendTo =
    SendTo


recvFrom : RecvFromRecord -> Transaction
recvFrom =
    RecvFrom


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


encode : Transaction -> E.Value
encode t =
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
        , ( "mtcn", MTCN.encode r.mtcn )
        ]


decoder : D.Decoder Transaction
decoder =
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
        (D.field "mtcn" MTCN.decoder)



--


viewSendTo :
    { zone : Time.Zone
    , edit : SendToRecord -> msg
    , remove : Ulid -> msg
    }
    -> Transaction
    -> List (Html msg)
viewSendTo { zone, edit, remove } t =
    case t of
        SendTo r ->
            [ div [ class "border p-4", class " --hover:bg-blue-100 --cursor-pointer" ]
                [ viewSendToDetail zone r True
                , div [ class "flex space-x-2 pt-4" ]
                    [ a
                        [ onClick <| edit r
                        , title "Edit/編集"
                        , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-blue-500 hover:bg-blue-300"
                        ]
                        [ Icons.pencil "w-4 h-4 text-white group-hover:text-gray-500"
                        ]
                    , a
                        [ onClick <| remove r.ulid
                        , title "Delete/削除"
                        , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-red-500 hover:bg-red-300"
                        ]
                        [ Icons.trash "w-4 h-4 text-white group-hover:text-gray-500"
                        ]
                    ]
                ]
            ]

        _ ->
            []


viewRecvFrom :
    { zone : Time.Zone
    , edit : RecvFromRecord -> msg
    , remove : Ulid -> msg
    }
    -> Transaction
    -> List (Html msg)
viewRecvFrom { zone, edit, remove } t =
    case t of
        RecvFrom r ->
            [ div [ class "border p-4", class "--hover:bg-blue-100 --cursor-pointer" ]
                [ viewRecvFromDetail zone r True
                , div [ class "flex space-x-2 pt-4" ]
                    [ a
                        [ onClick <| edit r
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
                ]
            ]

        _ ->
            []


viewPreview : Time.Zone -> List Transaction -> List (Html msg)
viewPreview zone ts =
    let
        send =
            List.filterMap
                (\t ->
                    case t of
                        SendTo r ->
                            Just r

                        _ ->
                            Nothing
                )
                ts

        recv =
            List.filterMap
                (\t ->
                    case t of
                        RecvFrom r ->
                            Just r

                        _ ->
                            Nothing
                )
                ts
    in
    List.map (viewSendToPreview zone) send ++ List.map (viewRecvFromPreview zone) recv


viewSendToPreview : Time.Zone -> SendToRecord -> Html msg
viewSendToPreview zone r =
    div [ class "border p-4" ]
        [ h2 [ class "font-bold" ] [ text "Recipient Information 受取人様情報" ]
        , viewSendToDetail zone r False
        ]


viewRecvFromPreview : Time.Zone -> RecvFromRecord -> Html msg
viewRecvFromPreview zone r =
    div [ class "border p-4" ]
        [ h2 [ class "font-bold" ] [ text "Sender's Information 送金人様情報" ]
        , viewRecvFromDetail zone r False
        ]


viewSendToDetail : Time.Zone -> SendToRecord -> Bool -> Html msg
viewSendToDetail zone r showTime =
    div [ class "grid grid-cols-1 print:grid-cols-3 sm:grid-cols-3 col-gap-4 row-gap-4" ]
        [ if showTime then
            div [ class "sm:col-span-3" ]
                [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Last time used（最後に使った日時）" ]
                , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| posixToDateTime zone r.posix ]
                ]

          else
            div [ class "sm:col-span-3" ] [ text "" ]
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
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| FormUtils.formatFloatPrice r.amount ]
            ]
        , div []
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Currency（通貨）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b truncate" ] [ text <| PayoutCountry.lookup r.countryCode ]
            ]
        , div []
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Purpose（送金目的）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| Data.Purpose.toString r.purpose ]
            ]
        ]


viewRecvFromDetail : Time.Zone -> RecvFromRecord -> Bool -> Html msg
viewRecvFromDetail zone r showTime =
    div [ class "grid grid-cols-1 print:grid-cols-3 sm:grid-cols-3 col-gap-4 row-gap-4" ]
        [ if showTime then
            div [ class "sm:col-span-3" ]
                [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Last time used（最後に使った日時）" ]
                , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| posixToDateTime zone r.posix ]
                ]

          else
            div [ class "sm:col-span-3" ] [ text "" ]
        , div [ class "sm:col-span-3" ]
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "MTCN（送金管理番号）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| MTCN.toString r.mtcn ]
            ]
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
            [ div [ class "text-sm leading-5 font-medium text-gray-500" ] [ text "Amount Expected（予想受取額）" ]
            , div [ class "mt-1 text-sm leading-5 text-gray-900 border-b" ] [ text <| FormUtils.formatFloatPrice r.amount ++ "円（JPY）" ]
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
