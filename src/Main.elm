port module Main exposing (main)

import AssocSet as Set exposing (Set)
import Browser
import CustomerForm
import Data.Occupation
import FormUtils
import Html exposing (..)
import Html.Attributes exposing (class, href, src, target, title)
import Html.Events exposing (..)
import Icons
import Json.Decode as D
import Json.Encode as E
import Modals
import Preview
import Random
import RecvFromForm
import SendToForm
import Task
import Time exposing (Posix)
import Types.Customer as Customer exposing (Customer)
import Types.MyNumber
import Types.Transaction as Transaction exposing (Transaction)
import Ulid exposing (Ulid)


type alias Model =
    { state : State
    , zone : Time.Zone
    , ts : List Transaction
    , picked : Set Ulid
    , modal : Modal
    }


type State
    = NotRegistered CustomerForm.Model
    | Registered Customer
    | Preview Customer
    | EditSendTo Customer SendToForm.Model
    | EditRecvFrom Customer RecvFromForm.Model


type Modal
    = None
    | DangerModal (Modals.SimpleWithDismissConfig Msg)
    | AlertModal (Modals.AlertConfig Msg)


main : Program E.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }



--


type Msg
    = CustomerFormMsg CustomerForm.Msg
    | ClickedReset
    | ClickedEdit
    | ClickedAddSendTo
    | ClickedAddRecvFrom
    | GotNewTimeSendTo Posix
    | GotUlidSendTo Ulid
    | SendToFormMsg SendToForm.Msg
    | RecvFromFormMsg RecvFromForm.Msg
    | GotNewTimeRecvFrom Posix
    | GotUlidRecvFrom Ulid
    | AdjustTimeZone Time.Zone
    | ClickedEditSendTo Transaction.SendToRecord
    | ClickedEditRecvFrom Transaction.RecvFromRecord
    | ClickedRemove Ulid
    | ClickedRemoveOk Ulid
    | ClickedRemoveCancel
    | ClickedPreview
    | ClickedClosePreview Customer
    | ClickedPrintPreview
    | ClickedPick Ulid
    | ClickedDismiss


init : E.Value -> ( Model, Cmd Msg )
init flags =
    ( case D.decodeValue decoder flags of
        Ok model ->
            model

        Err _ ->
            { state = NotRegistered CustomerForm.initialModel
            , zone = Time.utc
            , ts = []
            , picked = Set.empty
            , modal = None
            }
    , Task.perform AdjustTimeZone Time.here
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.state of
        NotRegistered form ->
            case msg of
                CustomerFormMsg m ->
                    CustomerForm.update m form
                        |> (\( form_, msg_ ) ->
                                case CustomerForm.isValid form_ of
                                    Just customer ->
                                        ( { model | state = Registered customer }, Cmd.none )

                                    Nothing ->
                                        ( { model | state = NotRegistered form_ }
                                        , Cmd.map CustomerFormMsg msg_
                                        )
                           )

                AdjustTimeZone zone ->
                    ( { model | zone = zone }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Registered c ->
            case msg of
                -- Customer
                ClickedReset ->
                    ( { model | state = NotRegistered CustomerForm.initialModel }, Cmd.none )

                ClickedEdit ->
                    ( { model | state = NotRegistered <| CustomerForm.edit c }, Cmd.none )

                -- SendTo
                ClickedAddSendTo ->
                    ( model, Task.perform GotNewTimeSendTo Time.now )

                GotNewTimeSendTo posix ->
                    ( model, newUlid GotUlidSendTo posix )

                GotUlidSendTo ulid ->
                    ( { model | state = EditSendTo c (SendToForm.initialModel ulid) }, Cmd.none )

                ClickedEditSendTo r ->
                    ( { model | state = EditSendTo c (SendToForm.edit r) }, Cmd.none )

                -- RecvFrom
                ClickedAddRecvFrom ->
                    ( model, Task.perform GotNewTimeRecvFrom Time.now )

                GotNewTimeRecvFrom posix ->
                    ( model, newUlid GotUlidRecvFrom posix )

                GotUlidRecvFrom ulid ->
                    ( { model | state = EditRecvFrom c (RecvFromForm.initialModel ulid) }, Cmd.none )

                ClickedEditRecvFrom r ->
                    ( { model | state = EditRecvFrom c (RecvFromForm.edit r) }, Cmd.none )

                --
                AdjustTimeZone zone ->
                    ( { model | zone = zone }, Cmd.none )

                ClickedPreview ->
                    ( { model | state = Preview c }, Cmd.none )

                ClickedRemove ulid ->
                    ( { model
                        | modal =
                            DangerModal
                                { title = "Delete/削除"
                                , message = "Are you sure you want to remove this memo ? このメモを削除してよろしいですか？"
                                , okText = "Delete/削除"
                                , cancelText = "Cancel"
                                , okCmd = ClickedRemoveOk ulid
                                , cancelCmd = ClickedRemoveCancel
                                }
                      }
                    , toggleModal <| E.bool True
                    )

                ClickedRemoveOk ulid ->
                    ( { model
                        | ts = Transaction.removeTransaction ulid model.ts
                        , picked = Set.remove ulid model.picked
                        , modal = None
                      }
                    , toggleModal <| E.bool False
                    )

                ClickedRemoveCancel ->
                    ( { model | modal = None }, toggleModal <| E.bool False )

                ClickedPick ulid ->
                    if Set.member ulid model.picked then
                        ( { model | picked = Set.remove ulid model.picked }, Cmd.none )

                    else if Set.size model.picked >= 3 then
                        ( { model | modal = AlertModal { title = "Too many items picked !", message = "一度に選択できるフォームは3個までです", okText = "閉じる", okCmd = ClickedDismiss } }, toggleModal <| E.bool True )

                    else
                        ( { model | picked = Set.insert ulid model.picked }, Cmd.none )

                ClickedDismiss ->
                    ( { model | modal = None }, toggleModal <| E.bool False )

                _ ->
                    ( model, Cmd.none )

        Preview _ ->
            case msg of
                ClickedClosePreview c ->
                    ( { model | state = Registered c }, Cmd.none )

                ClickedPrintPreview ->
                    ( model, printWindow E.null )

                _ ->
                    ( model, Cmd.none )

        EditSendTo c model_ ->
            case msg of
                SendToFormMsg msg_ ->
                    SendToForm.update msg_ model_
                        |> (\( newModel, cmds ) ->
                                if SendToForm.isCanceled newModel then
                                    ( { model | state = Registered c }, Cmd.none )

                                else
                                    case SendToForm.isValid newModel of
                                        Just sendTo ->
                                            ( { model
                                                | state = Registered c
                                                , ts = Transaction.upsert (Transaction.sendTo sendTo) model.ts
                                              }
                                            , Cmd.map SendToFormMsg cmds
                                            )

                                        Nothing ->
                                            ( { model | state = EditSendTo c newModel }, Cmd.map SendToFormMsg cmds )
                           )

                _ ->
                    ( model, Cmd.none )

        EditRecvFrom c model_ ->
            case msg of
                RecvFromFormMsg msg_ ->
                    RecvFromForm.update msg_ model_
                        |> (\( newModel, cmds ) ->
                                if RecvFromForm.isCanceled newModel then
                                    ( { model | state = Registered c }, Cmd.none )

                                else
                                    case RecvFromForm.isValid newModel of
                                        Just recvFrom ->
                                            ( { model
                                                | state = Registered c
                                                , ts = Transaction.upsert (Transaction.recvFrom recvFrom) model.ts
                                              }
                                            , Cmd.map RecvFromFormMsg cmds
                                            )

                                        Nothing ->
                                            ( { model | state = EditRecvFrom c newModel }, Cmd.map RecvFromFormMsg cmds )
                           )

                _ ->
                    ( model, Cmd.none )


newUlid : (Ulid -> Msg) -> Posix -> Cmd Msg
newUlid msg posix =
    Random.generate msg (Ulid.ulidGenerator posix)



-- buildUlid integer =
--     let
--         initialSeed =
--             Random.initialSeed integer
--         ( newUlid, seed ) =
--             step (Ulid.ulidGenerator time) initialSeed
--     in
--     newUlid
--


container : Html msg -> Html msg
container content =
    div [ class "bg-gray-400 py-2 sm:py-8 px-2 sm:px-6 lg:px-8 min-h-screen" ]
        [ div [ class "bg-white relative mx-auto max-w-6xl" ]
            [ div [ class "px-4 sm:px-16 pt-8 pb-4" ]
                [ h1 [ class "text-xl font-bold flex flex-col sm:flex-row" ]
                    [ img [ src "/logo.wu.big.svg", class "inline w-40 bg-black mr-3" ] []
                    , span [ class "mt-1" ] [ text "Transaction Form / 送金メモ" ]
                    ]

                -- , ol [ class "ml-4 text-sm" ]
                --     [ li [] [ text "1. Fill in your information." ]
                --     , li [] [ text "2. Add Sender or Recipient Information" ]
                --     , li [] [ text "3. Choose upto three transactions" ]
                --     , li [] [ text "4. Print out the memo" ]
                --     ]
                , p [ class "ml-4 text-sm py-1" ]
                    [ text "Please bring the completed form before visiting us ! 1. Fill in your information 2. Add Recipient or Sender Information 3. Choose upto three transactions 4. Print-out or take a screen shot !" ]
                , p [ class "ml-4 text-sm py-1" ]
                    [ text "こちらのフォームをご来店前に作成してお持ちいただくとスムーズにお手続きが可能です。1. お客様情報の入力 2. 受取人または送金人の情報を入力 3. 一度に3件まで選択可能です 4. 印刷またはスクリーンショットを撮ってださい" ]
                ]
            , content
            , div [ class "text-sm leading-6 text-gray-400 text-center pb-4" ]
                [ p [] [ text "tel: 048-987-1020 / 10:00am - 7:30pm" ]
                , p [] [ a [ href "https://www.officeiko.co.jp/", target "_blank" ] [ text "© 2020 Office IKO Co. All rights reserved." ] ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    case model.state of
        Preview c ->
            Preview.view
                { customer = c
                , ts = List.filter (\t -> Transaction.member t model.picked) model.ts
                , zone = model.zone
                , close = ClickedClosePreview c
                , print = ClickedPrintPreview
                }

        NotRegistered form ->
            container (CustomerForm.contactForm form |> Html.map CustomerFormMsg)

        Registered c ->
            container <|
                div [ class "px-4 sm:px-16" ]
                    [ div [ class "flex pb-4" ]
                        [ h2 [ class "font-bold" ] [ text "Your Information お客様情報" ]
                        , div [ class "flex ml-2 space-x-2" ]
                            [ span [ class "inline-flex rounded-md shadow-sm" ]
                                [ button
                                    [ onClick ClickedEdit
                                    , title "Edit/編集"
                                    , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-blue-500 hover:bg-blue-300"
                                    ]
                                    [ Icons.pencil "w-4 h-4 text-white group-hover:text-gray-500"
                                    ]
                                ]
                            , span [ class "inline-flex" ]
                                [ button
                                    [ onClick ClickedReset
                                    , title "Reset/リセット"
                                    , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-red-500 hover:bg-red-300"
                                    ]
                                    [ Icons.trash "w-4 h-4 text-white group-hover:text-gray-500"
                                    ]
                                ]
                            ]
                        ]
                    , div [ class "grid grid-cols-1 sm:grid-cols-3 col-gap-4 row-gap-8" ]
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
                    , div [ class "my-4 py-4" ]
                        [ div [ class "flex pb-4" ]
                            [ h2 [ class "font-bold" ] [ text "Send To（送金先）" ]
                            , button
                                [ onClick ClickedAddSendTo
                                , title "Add/追加"
                                , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-blue-500 hover:bg-blue-300"
                                ]
                                [ Icons.plus "w-4 h-4 text-white group-hover:text-gray-500"
                                ]
                            , h5 [ class "text-xs text-gray-800 leading-1 ml-2 mt-1" ] [ text "送金したい相手の情報を入力してください" ]
                            ]
                        , div [ class "space-y-4" ] <|
                            case
                                List.map
                                    (Transaction.viewSendTo
                                        { zone = model.zone
                                        , edit = ClickedEditSendTo
                                        , remove = ClickedRemove
                                        , picked = Set.toList model.picked
                                        , pick = ClickedPick
                                        }
                                    )
                                    model.ts
                                    |> List.concat
                            of
                                [] ->
                                    [ div
                                        [ class "flex justify-center items-center py-8 border border-blue-500 bg-gray-100 hover:bg-blue-200 cursor-pointer text-center"
                                        , onClick ClickedAddSendTo
                                        ]
                                        [ text "Add New Recipient"
                                        , br [] []
                                        , text "送金先を追加"
                                        ]
                                    ]

                                children ->
                                    children
                        ]
                    , div [ class "my-4 py-4" ]
                        [ div [ class "flex pb-4" ]
                            [ h2 [ class "font-bold" ] [ text "Receive From（送金人）" ]
                            , button
                                [ onClick ClickedAddRecvFrom
                                , title "Add/追加"
                                , class "group flex items-center justify-center text-sm cursor-pointer rounded-full w-6 h-6 bg-blue-500 hover:bg-blue-300"
                                ]
                                [ Icons.plus "w-4 h-4 text-white group-hover:text-gray-500"
                                ]
                            , h5 [ class "text-xs text-gray-800 leading-1 ml-2 mt-1" ] [ text "送金された方の情報を入力してください" ]
                            ]
                        , div [ class "space-y-4" ] <|
                            case
                                List.map
                                    (Transaction.viewRecvFrom
                                        { zone = model.zone
                                        , edit = ClickedEditRecvFrom
                                        , remove = ClickedRemove
                                        , picked = Set.toList model.picked
                                        , pick = ClickedPick
                                        }
                                    )
                                    model.ts
                                    |> List.concat
                            of
                                [] ->
                                    [ div
                                        [ class "flex justify-center items-center py-8 border border-blue-500 bg-gray-100 hover:bg-blue-200 cursor-pointer text-center"
                                        , onClick ClickedAddRecvFrom
                                        ]
                                        [ text "Add New Sender"
                                        , br [] []
                                        , text "送金人を追加"
                                        ]
                                    ]

                                children ->
                                    children
                        ]
                    , div [ class "pb-4" ]
                        [ div [ class "flex print:hidden justify-center sm:justify-end" ]
                            [ FormUtils.okButton ClickedPreview "Print"
                            ]
                        ]
                    , case model.modal of
                        None ->
                            text ""

                        DangerModal config ->
                            Modals.simpleWithDismiss config

                        AlertModal config ->
                            Modals.alert config
                    ]

        EditSendTo c f ->
            SendToForm.view f |> Html.map SendToFormMsg |> container

        EditRecvFrom c f ->
            RecvFromForm.view f |> Html.map RecvFromFormMsg |> container



-- PORTS


port setStorage : E.Value -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) =
            update msg oldModel
    in
    ( newModel
    , Cmd.batch [ setStorage (encode newModel), cmds ]
    )


port printWindow : E.Value -> Cmd msg


port toggleModal : E.Value -> Cmd msg



--


encode : Model -> E.Value
encode model =
    E.object
        [ ( "state"
          , case model.state of
                NotRegistered form ->
                    E.object
                        [ ( "notRegistered"
                          , E.object [ ( "customerForm", CustomerForm.encode form ) ]
                          )
                        ]

                Registered c ->
                    E.object
                        [ ( "registered"
                          , E.object
                                [ ( "customer", Customer.encode c )
                                ]
                          )
                        ]

                Preview c ->
                    E.object
                        [ ( "registered"
                          , E.object
                                [ ( "customer", Customer.encode c )
                                ]
                          )
                        ]

                EditSendTo c f ->
                    E.object
                        [ ( "registered"
                          , E.object
                                [ ( "customer", Customer.encode c )
                                ]
                          )
                        ]

                EditRecvFrom c f ->
                    E.object
                        [ ( "registered"
                          , E.object
                                [ ( "customer", Customer.encode c )
                                ]
                          )
                        ]
          )
        , ( "transactions", E.list (\t -> Transaction.encode t) model.ts )
        , ( "picked", E.list (\p -> E.string <| Ulid.toString p) (Set.toList model.picked) )
        , ( "modal", E.null )
        ]



{---

{ 
    "state" : {
        "notRegistered" : {
            "customerForm" : {
                "firstName" : "Yasuyuki",
                "middleName" : "",
                "lastName" : "Komatsubara",
            }
        }
    },
    "transactions" : [],
    "picked" : [],
}

{ 
    "state" : {
        "registered" : {
            "customer" : {
                "firstName" : "Yasuyuki",
                "middleName" : "",
                "lastName" : "Komatsubara",
            },
        }
    },
    "transactions" : [],
    "picked" : [],
}

---}


decoder : D.Decoder Model
decoder =
    D.map5 Model
        (D.field "state"
            (D.oneOf
                [ D.field "notRegistered"
                    (D.map NotRegistered
                        (D.field "customerForm" CustomerForm.decoder)
                    )
                , D.field "registered"
                    (D.map Registered
                        (D.field "customer" Customer.decoder)
                    )
                ]
            )
        )
        (D.succeed Time.utc)
        (D.field "transactions" (D.list Transaction.decoder))
        (D.field "picked" (D.list Ulid.decode |> D.map Set.fromList))
        (D.succeed None)
