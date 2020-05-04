module CustomerForm exposing (Model, Msg, contactForm, decoder, edit, encode, initialModel, isValid, update)

import Data.Occupation exposing (Occupation)
import Form.Decoder as FD
import FormUtils exposing (Error, field)
import Html exposing (..)
import Html.Attributes exposing (class, name, type_, value)
import Html.Events exposing (onClick)
import Json.Decode as D
import Json.Encode as E
import Types.Customer as Customer exposing (Customer)
import Types.MyNumber exposing (MyNumber)
import Types.Name


type alias Model =
    { f : CustomerForm
    , customer : Maybe Customer
    , submitted : Bool
    }


type alias CustomerForm =
    { firstName : String
    , middleName : String
    , lastName : String
    , tel : String
    , myNumber : String
    , occupation : Occupation
    , nationality : String
    }


initialModel : Model
initialModel =
    { f = emptyForm
    , customer = Nothing
    , submitted = False
    }


emptyForm : CustomerForm
emptyForm =
    { firstName = ""
    , middleName = ""
    , lastName = ""
    , tel = ""
    , myNumber = ""
    , occupation = Data.Occupation.default
    , nationality = ""
    }


edit : Customer -> Model
edit c =
    { firstName = c.name.firstName
    , middleName = Maybe.withDefault "" c.name.middleName
    , lastName = c.name.lastName
    , tel = c.tel
    , myNumber = Maybe.withDefault "" <| Maybe.map Types.MyNumber.toString c.myNumber
    , occupation = c.occupation
    , nationality = c.nationality
    }
        |> (\f ->
                { f = f
                , customer = Just c
                , submitted = False
                }
           )


encode : Model -> E.Value
encode model =
    E.object
        [ ( "form", encodeCustomerForm model.f )
        , ( "customer", Maybe.map Customer.encode model.customer |> Maybe.withDefault E.null )
        , ( "submitted", E.bool model.submitted )
        ]


encodeCustomerForm : CustomerForm -> E.Value
encodeCustomerForm f =
    E.object
        [ ( "firstName", E.string f.firstName )
        , ( "middleName", E.string f.middleName )
        , ( "lastName", E.string f.lastName )
        , ( "tel", E.string f.tel )
        , ( "myNumber", E.string f.myNumber )
        , ( "occupation", Data.Occupation.encode f.occupation )
        , ( "nationality", E.string f.nationality )
        ]


andMap : D.Decoder a -> D.Decoder (a -> b) -> D.Decoder b
andMap =
    D.map2 (|>)


decoder : D.Decoder Model
decoder =
    D.map3 Model
        (D.field "form" customerFormDecoder)
        (D.field "customer" (D.maybe Customer.decoder))
        (D.field "submitted" D.bool)


customerFormDecoder : D.Decoder CustomerForm
customerFormDecoder =
    D.succeed CustomerForm
        |> andMap (D.field "firstName" D.string)
        |> andMap (D.field "middleName" D.string)
        |> andMap (D.field "lastName" D.string)
        |> andMap (D.field "tel" D.string)
        |> andMap (D.field "myNumber" D.string)
        |> andMap (D.field "occupation" Data.Occupation.decoder)
        |> andMap (D.field "nationality" D.string)



--


type Msg
    = ChangedInput CustomerForm
    | ClickedRegister


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedInput f ->
            ( { model | f = f }, Cmd.none )

        ClickedRegister ->
            case FD.run formDecoder model.f of
                Ok customer ->
                    ( { model | submitted = True, customer = Just customer }, Cmd.none )

                Err _ ->
                    ( { model | submitted = True }, Cmd.none )


isValid : Model -> Maybe Customer
isValid model =
    if model.submitted then
        model.customer

    else
        Nothing



-- Form Decoder


formDecoder : FD.Decoder CustomerForm Error Customer
formDecoder =
    FD.map5 Customer
        Types.Name.formDecoder
        (FD.lift .tel tel)
        (FD.lift .myNumber myNumber)
        (FD.lift .occupation FD.identity)
        (FD.lift .nationality nationality)


tel : FD.Decoder String Error String
tel =
    FD.identity
        |> FD.assert FormUtils.required
        |> FD.assert (FD.minLength (FormUtils.fromString "TooShort ") 11)


myNumber : FD.Decoder String Error (Maybe MyNumber)
myNumber =
    Types.MyNumber.formDecoder
        |> FormUtils.optional


nationality : FD.Decoder String Error String
nationality =
    FD.identity
        |> FD.assert FormUtils.required



--


contactForm : Model -> Html Msg
contactForm { f, submitted } =
    div [ class "bg-white px-16 py-16" ]
        [ h2 [ class "p-2 font-black" ] [ text "Your Information お客様情報" ]
        , p [ class "px-2 text-sm" ] [ text "お名前はアルファベットで入力してください" ]
        , div [ class "flex flex-col sm:flex-row" ]
            [ field
                { v = f.firstName
                , l = "First Name (名)"
                , u = \s -> { f | firstName = String.toUpper s } |> ChangedInput
                , d = Types.Name.firstName
                , n = "given-name"
                , submitted = submitted
                }
            , field
                { v = f.middleName
                , l = "Middle Name（ミドルネーム）"
                , u = \s -> { f | middleName = String.toUpper s } |> ChangedInput
                , d = Types.Name.middleName
                , n = "additional-name"
                , submitted = submitted
                }
            , field
                { v = f.lastName
                , l = "Last Name（姓）"
                , u = \s -> { f | lastName = String.toUpper s } |> ChangedInput
                , d = Types.Name.lastName
                , n = "family-name"
                , submitted = submitted
                }
            ]
        , div [ class "flex flex-col sm:flex-row" ]
            [ field
                { v = f.myNumber
                , l = "My Number（個人番号）"
                , u = \s -> { f | myNumber = s } |> ChangedInput
                , d = myNumber
                , n = "my-number"
                , submitted = submitted
                }
            , field
                { v = f.tel
                , l = "Contact Phone No.（電話番号）"
                , u = \s -> { f | tel = s } |> ChangedInput
                , d = tel
                , n = "tel"
                , submitted = submitted
                }
            , field
                { v = f.nationality
                , l = "Nationality（国籍）"
                , u = \s -> { f | nationality = s } |> ChangedInput
                , d = nationality
                , n = "country-name"
                , submitted = submitted
                }
            ]
        , div [ class "ml-3 mb-4" ]
            [ div [ class "text-xs px-2" ] [ text "Occupation/職業" ]
            , div [ class "flex flex-wrap space-x-1" ]
                (List.map
                    (\( v, l ) ->
                        label
                            [ class "inline-flex justify-center items-center px-2 py-0.5 rounded text-xs font-medium leading-4 h-8 mb-2"
                            , if f.occupation == v then
                                class "bg-blue-100 text-blue-800"

                              else
                                class "bg-gray-100 text-gray-800 cursor-pointer hover:bg-blue-50"
                            ]
                            [ input
                                [ type_ "radio"
                                , name "occupation"
                                , value l
                                , onClick ({ f | occupation = v } |> ChangedInput)
                                , class "opacity-0"
                                ]
                                []
                            , span [ class "-ml-2" ] [ text l ]
                            ]
                    )
                    Data.Occupation.list
                )
            ]
        , div [ class "text-center" ]
            [ span [ class "inline-flex rounded-md shadow-sm" ]
                [ button
                    [ onClick ClickedRegister
                    , class "inline-flex w-24 justify-center items-center px-2.5 py-1.5 border border-transparent text-xs leading-4 font-medium rounded text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition ease-in-out duration-150"
                    ]
                    [ text "登録" ]
                ]
            ]
        ]
