module RecvFromForm exposing (Model, Msg, edit, initialModel, isCanceled, isValid, update, view)

import Data.Purpose exposing (Purpose)
import Form.Decoder as FD
import FormUtils exposing (Error, field)
import Html exposing (..)
import Html.Attributes exposing (class, title)
import Html.Events exposing (onClick)
import Task
import Time exposing (Posix)
import Types.MTCN as MTCN exposing (MTCN)
import Types.Name
import Types.Transaction as Transaction
import Ulid exposing (Ulid)


type alias Model =
    { form : Form
    , ulid : Ulid
    , record : Maybe Transaction.RecvFromRecord
    , submitted : Bool
    , canceled : Bool
    }


initialModel : Ulid -> Model
initialModel ulid =
    { form = emptyForm
    , ulid = ulid
    , record = Nothing
    , submitted = False
    , canceled = False
    }


type alias Form =
    { firstName : String
    , middleName : String
    , lastName : String
    , amount : String
    , purpose : Purpose
    , mtcn : String
    }


emptyForm : Form
emptyForm =
    { firstName = ""
    , middleName = ""
    , lastName = ""
    , amount = ""
    , purpose = Data.Purpose.default
    , mtcn = ""
    }


edit : Transaction.RecvFromRecord -> Model
edit r =
    { form =
        { firstName = r.name.firstName
        , middleName = Maybe.withDefault "" r.name.middleName
        , lastName = r.name.lastName
        , amount = String.fromFloat r.amount
        , purpose = r.purpose
        , mtcn = MTCN.toString r.mtcn
        }
    , ulid = r.ulid
    , record = Just r
    , submitted = False
    , canceled = False
    }


isValid : Model -> Maybe Transaction.RecvFromRecord
isValid model =
    if model.submitted then
        model.record

    else
        Nothing


isCanceled : Model -> Bool
isCanceled model =
    model.canceled


type Msg
    = ChangedInput Form
    | ClickedRegister
    | ClickedClose
    | GotTime Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedInput f ->
            ( { model | form = f }, Cmd.none )

        ClickedRegister ->
            ( model, Task.perform GotTime Time.now )

        GotTime posix ->
            case FD.run (formDecoder model.ulid posix) model.form of
                Ok r ->
                    ( { model | submitted = True, record = Just r }, Cmd.none )

                Err _ ->
                    ( { model | submitted = True, record = Nothing }, Cmd.none )

        ClickedClose ->
            ( { model | canceled = True }, Cmd.none )



-- Form Decoder


formDecoder : Ulid -> Posix -> FD.Decoder Form Error Transaction.RecvFromRecord
formDecoder ulid posix =
    FD.top Transaction.RecvFromRecord
        |> FD.field (FD.always ulid)
        |> FD.field (FD.always posix)
        |> FD.field Types.Name.formDecoder
        |> FD.field (FD.lift .amount amount)
        |> FD.field (FD.lift .purpose FD.identity)
        |> FD.field (FD.lift .mtcn mtcn)


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


mtcn : FD.Decoder String Error MTCN
mtcn =
    FD.identity
        |> FD.map MTCN.fromString



--


view : Model -> Html Msg
view { form, submitted } =
    div [ class "bg-white px-4 py-4 sm:px-16 sm:py-8 border-t border-gray-200" ]
        [ h2 [ class "p-2 font-black" ] [ text "Sender's Information 送金人様情報" ]
        , p [ class "px-2 text-sm" ] [ text "お名前はアルファベットで入力してください" ]
        , div [ class "grid grid-cols-1 sm:grid-cols-3 col-gap-4" ]
            [ div [ class "sm:col-span-3" ]
                [ field
                    { v = form.mtcn
                    , l = "MTCN（送金管理番号）"
                    , u = \s -> { form | mtcn = s } |> ChangedInput
                    , d = mtcn
                    , n = "mtcn"
                    , submitted = submitted
                    }
                ]
            , field
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
                , l = "Amount Expected （予想受取額）"
                , u = \s -> { form | amount = s } |> ChangedInput
                , d = amount
                , n = "amount"
                , submitted = submitted
                }
            , div [ class "sm:col-span-3" ]
                [ Data.Purpose.view form ChangedInput ]
            , div [ class "mt-8 border-t border-gray-200 pt-5 col-span-1 sm:col-span-3" ]
                [ div [ class "flex print:hidden justify-center sm:justify-end" ]
                    [ FormUtils.cancelButton ClickedClose "Cancel"
                    , FormUtils.okButton ClickedRegister "Save"
                    ]
                ]
            ]
        ]
