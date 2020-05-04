module SendToForm exposing (Model, Msg, edit, initialModel, isValid, update, view)

import Data.PayoutCountry
import Data.Purpose exposing (Purpose)
import Form.Decoder as FD
import FormUtils exposing (Error, field)
import Html exposing (..)
import Html.Attributes exposing (class, name, type_, value)
import Html.Events exposing (..)
import Task
import Time exposing (Posix)
import Types.Customer exposing (Customer)
import Types.Name
import Types.Transaction as Transaction
import Ulid exposing (Ulid)


type alias Model =
    { form : Form
    , ulid : Ulid
    , sendToRecord : Maybe Transaction.SendToRecord
    , payoutCountryState : Data.PayoutCountry.State
    , submitted : Bool
    }


initialModel : Ulid -> Model
initialModel ulid =
    { form = emptyForm
    , ulid = ulid
    , sendToRecord = Nothing
    , payoutCountryState = Data.PayoutCountry.initialState Data.PayoutCountry.default
    , submitted = False
    }


type alias Form =
    { firstName : String
    , middleName : String
    , lastName : String
    , amount : String
    , countryCode : Data.PayoutCountry.Code
    , purpose : Purpose
    }


emptyForm : Form
emptyForm =
    { firstName = ""
    , middleName = ""
    , lastName = ""
    , amount = ""
    , countryCode = Data.PayoutCountry.default
    , purpose = Data.Purpose.default
    }


edit : Transaction.SendToRecord -> Model
edit r =
    { form =
        { firstName = r.name.firstName
        , middleName = Maybe.withDefault "" r.name.middleName
        , lastName = r.name.lastName
        , amount = String.fromFloat r.amount
        , countryCode = r.countryCode
        , purpose = r.purpose
        }
    , ulid = r.ulid
    , sendToRecord = Just r
    , payoutCountryState = Data.PayoutCountry.initialState r.countryCode
    , submitted = False
    }


isValid : Model -> Maybe Transaction.SendToRecord
isValid model =
    if model.submitted then
        model.sendToRecord

    else
        Nothing


type Msg
    = ChangedInput Form
    | ClickedRegister
    | PayoutCountryMsg Data.PayoutCountry.Msg
    | GotTime Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ form } as model) =
    case msg of
        ChangedInput f ->
            ( { model | form = f }, Cmd.none )

        ClickedRegister ->
            ( model, Task.perform GotTime Time.now )

        GotTime posix ->
            case FD.run (formDecoder model.ulid posix) model.form of
                Ok r ->
                    ( { model | submitted = True, sendToRecord = Just r }, Cmd.none )

                Err errs ->
                    ( { model | submitted = True, sendToRecord = Nothing }, Cmd.none )

        PayoutCountryMsg msg_ ->
            Data.PayoutCountry.update msg_ model.payoutCountryState
                |> (\state ->
                        case Data.PayoutCountry.selected state of
                            Just ( code, label ) ->
                                ( { model | payoutCountryState = state, form = { form | countryCode = code } }, Cmd.none )

                            Nothing ->
                                ( { model | payoutCountryState = state }, Cmd.none )
                   )



-- Form Decoder


formDecoder : Ulid -> Posix -> FD.Decoder Form Error Transaction.SendToRecord
formDecoder ulid posix =
    FD.top Transaction.SendToRecord
        |> FD.field (FD.always ulid)
        |> FD.field (FD.always posix)
        |> FD.field Types.Name.formDecoder
        |> FD.field (FD.lift .amount amount)
        |> FD.field (FD.lift .countryCode FD.identity)
        |> FD.field (FD.lift .purpose FD.identity)


amount : FD.Decoder String Error Float
amount =
    FD.identity
        -- |> FD.assert (FD.float (Types.Error.fromString "数字で入力してください"))
        |> FD.andThen
            (\s ->
                case String.toFloat s of
                    Just f ->
                        FD.always f

                    Nothing ->
                        FD.fail (FormUtils.fromString "数字で入力してください")
            )



--


view : Model -> Html Msg
view { form, submitted, payoutCountryState } =
    div [ class "bg-white px-4 py-4 sm:px-16 sm:py-16 border rounded border-gray-200" ]
        [ h2 [ class "p-2 font-black" ] [ text "Recipient Information 受取人様情報" ]
        , p [ class "px-2 text-sm" ] [ text "お名前はアルファベットで入力してください" ]
        , div [ class "grid grid-cols-1 sm:grid-cols-3 col-gap-4" ]
            [ field
                { v = form.firstName
                , l = "First Name (名)"
                , u = \s -> { form | firstName = String.toUpper s } |> ChangedInput
                , d = Types.Name.firstName
                , n = "given-name"
                , submitted = submitted
                }
            , field
                { v = form.middleName
                , l = "Middle Name（ミドルネーム）"
                , u = \s -> { form | middleName = String.toUpper s } |> ChangedInput
                , d = Types.Name.middleName
                , n = "additional-name"
                , submitted = submitted
                }
            , field
                { v = form.lastName
                , l = "Last Name（姓）"
                , u = \s -> { form | lastName = String.toUpper s } |> ChangedInput
                , d = Types.Name.lastName
                , n = "family-name"
                , submitted = submitted
                }
            , field
                { v = form.amount
                , l = "Amount to be sent （送金額）"
                , u = \s -> { form | amount = s } |> ChangedInput
                , d = amount
                , n = "amount"
                , submitted = submitted
                }
            , div [ class "sm:col-span-2" ] [ Data.PayoutCountry.selector payoutCountryState |> Html.map PayoutCountryMsg ]
            , div [ class "sm:col-span-3" ]
                [ Data.Purpose.view form ChangedInput ]
            , div [] [ button [ onClick ClickedRegister ] [ text "登録" ] ]
            ]
        ]



--
