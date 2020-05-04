port module Main exposing (main)

import AssocSet as Set exposing (Set)
import Browser
import CustomerForm
import Data.Occupation
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Preview
import Random
import SendToForm
import Task
import Time exposing (Posix)
import Types
import Types.MyNumber
import Ulid exposing (Ulid)


type alias Model =
    { state : State
    , zone : Time.Zone
    , ts : List Types.Transaction
    , picked : Set Ulid
    , modal : Modal
    }


type State
    = NotRegistered CustomerForm.Model
    | Registered Types.Customer
    | Preview Types.Customer


type Modal
    = SendTo SendToForm.Model
    | RecvFrom
    | None


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
    | GotNewTime Posix
    | GotUlid Ulid
    | SendToFormMsg SendToForm.Msg
    | AdjustTimeZone Time.Zone
    | ClickedEditTransaction Types.Transaction
    | ClickedRemoveSendTo Ulid
    | ClickedPreview
    | ClickedClosePreview Types.Customer
    | ClickedPrintPreview


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
                ClickedReset ->
                    ( { model | state = NotRegistered CustomerForm.initialModel }, Cmd.none )

                ClickedEdit ->
                    ( { model | state = NotRegistered <| CustomerForm.edit c }, Cmd.none )

                ClickedAddSendTo ->
                    ( model, Task.perform GotNewTime Time.now )

                SendToFormMsg msg_ ->
                    case model.modal of
                        SendTo model_ ->
                            SendToForm.update msg_ model_
                                |> (\( newModel, cmds ) ->
                                        case SendToForm.isValid newModel of
                                            Just sendTo ->
                                                ( { model | state = Registered c, ts = Types.sendTo sendTo :: model.ts, modal = None }, Cmd.map SendToFormMsg cmds )

                                            Nothing ->
                                                ( { model | modal = SendTo newModel }, Cmd.map SendToFormMsg cmds )
                                   )

                        _ ->
                            ( model, Cmd.none )

                GotNewTime posix ->
                    ( model, newUlid posix )

                GotUlid ulid ->
                    ( { model | modal = SendTo (SendToForm.initialModel ulid) }, Cmd.none )

                -- ClickedEditTransaction t ->
                --     ( { model | modal =})
                ClickedAddRecvFrom ->
                    ( model, Cmd.none )

                AdjustTimeZone zone ->
                    ( { model | zone = zone }, Cmd.none )

                ClickedRemoveSendTo ulid ->
                    ( { model
                        | ts = Types.removeTransaction ulid model.ts
                        , picked = Set.remove ulid model.picked
                      }
                    , Cmd.none
                    )

                ClickedPreview ->
                    ( { model | state = Preview c }, Cmd.none )

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


newUlid : Posix -> Cmd Msg
newUlid posix =
    Random.generate GotUlid (Ulid.ulidGenerator posix)



-- buildUlid integer =
--     let
--         initialSeed =
--             Random.initialSeed integer
--         ( newUlid, seed ) =
--             step (Ulid.ulidGenerator time) initialSeed
--     in
--     newUlid
--


header : Html msg -> Html msg
header content =
    div [ class "bg-gray-400 py-8 px-4 sm:px-6 lg:px-8" ]
        [ div [ class "bg-white relative mx-auto max-w-6xl" ]
            [ div [ class "px-16 pt-8" ]
                [ h1 [ class "text-xl font-bold" ] [ text "Western Union Preparation Form / ウェスタンユニオン 送金メモ" ]
                , ol [ class "ml-4 text-sm" ]
                    [ li [] [ text "1. Fill in your information." ]
                    , li [] [ text "2. Add Sender or Recipient Information" ]
                    , li [] [ text "3. Choose upto three transactions" ]
                    , li [] [ text "4. Print out the memo" ]
                    ]
                ]
            , content
            ]
        ]


view : Model -> Html Msg
view model =
    case model.state of
        Preview c ->
            Preview.view { customer = c, ts = model.ts, zone = model.zone, close = ClickedClosePreview c, print = ClickedPrintPreview }

        NotRegistered form ->
            header (CustomerForm.contactForm form |> Html.map CustomerFormMsg)

        Registered c ->
            header <|
                div [ class "px-16" ]
                    [ div [ class "flex border-b my-8" ]
                        [ h2 [ class "font-bold" ] [ text "Your Information お客様情報" ]
                        , div [ class "flex" ]
                            [ span [ class "inline-flex" ]
                                [ button
                                    [ onClick ClickedReset
                                    , class "inline-flex items-center px-2 py-1.5 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                                    ]
                                    [ text "リセット" ]
                                ]
                            , span [ class "inline-flex rounded-md shadow-sm" ]
                                [ button
                                    [ onClick ClickedEdit
                                    , class "inline-flex items-center px-2 py-1.5 border border-transparent text-xs leading-4 font-medium rounded text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition ease-in-out duration-150"
                                    ]
                                    [ text "編集" ]
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
                    , div [ class "border-b-4 my-8 py-4" ]
                        [ div [ class "flex" ]
                            [ h2 [ class "font-bold" ] [ text "Send To（送金先）" ]
                            , button
                                [ onClick ClickedAddSendTo
                                , class "inline-flex items-center px-2 py-1.5 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                                ]
                                [ text "追加"
                                ]
                            ]
                        , div [ class "space-y-4" ] <|
                            List.map (Types.viewTransaction { zone = model.zone, edit = ClickedEditTransaction, remove = ClickedRemoveSendTo }) model.ts
                        ]
                    , div [ class "border-b-4 my-8 py-4" ]
                        [ div [ class "flex" ]
                            [ h2 [ class "font-bold" ] [ text "Receive From（受取先）" ]
                            , button
                                [ class "inline-flex items-center px-2 py-1.5 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150" ]
                                [ text "追加"
                                ]
                            ]
                        , div [ class "space-y-4" ] <|
                            List.map (Types.viewTransaction { zone = model.zone, edit = ClickedEditTransaction, remove = ClickedRemoveSendTo }) model.ts
                        ]
                    , div [ class "pb-8 text-center" ]
                        [ button
                            [ class "rounded mx-2 px-2 py-1 w-24 bg-blue-700 text-white font-bold"
                            , onClick ClickedPreview
                            ]
                            [ text "Print" ]
                        , button [ class "rounded mx-2 px-2 py-1 w-24 bg-red-700 text-white font-bold" ] [ text "Clear All" ]
                        ]
                    , case model.modal of
                        SendTo form ->
                            modal (SendToForm.view form |> Html.map SendToFormMsg)

                        RecvFrom ->
                            text ""

                        None ->
                            text ""
                    ]


modal : Html msg -> Html msg
modal html =
    div [ class "fixed bottom-0 inset-x-0 px-4 pb-6 sm:inset-0 sm:p-0 flex items-center justify-center" ]
        [ div [ class "fixed inset-0 transition-opcaity" ]
            [ div [ class "absolute inset-0 bg-gray-500 opacity-75" ] []
            ]
        , div [ class "bg-white rounded-lg px-4 pt-2 pb-2 overflow-hidden shadow-xl transform transition-all sm:max-w-6xl sm:w-full sm:p-6" ] [ html ]
        ]



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
                                [ ( "customer", Types.encodeCustomer c )
                                ]
                          )
                        ]

                Preview c ->
                    E.object
                        [ ( "registered"
                          , E.object
                                [ ( "customer", Types.encodeCustomer c )
                                ]
                          )
                        ]
          )
        , ( "transactions", E.list (\t -> Types.encodeTransaction t) model.ts )
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
                        (D.field "customer" Types.customerDecoder)
                    )
                ]
            )
        )
        (D.succeed Time.utc)
        (D.field "transactions" (D.list Types.transactionDecoder))
        (D.field "picked" (D.list Ulid.decode |> D.map Set.fromList))
        (D.succeed None)
