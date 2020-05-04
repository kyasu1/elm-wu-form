module Types.Name exposing (..)

import Form.Decoder as FD
import FormUtils exposing (Error)
import Json.Decode as D
import Json.Encode as E


type alias Name =
    { firstName : String
    , middleName : Maybe String
    , lastName : String
    }


encode : Name -> E.Value
encode name =
    E.object
        [ ( "firstName", E.string name.firstName )
        , ( "middleName", Maybe.map E.string name.middleName |> Maybe.withDefault E.null )
        , ( "lastName", E.string name.lastName )
        ]


decoder : D.Decoder Name
decoder =
    D.map3 Name
        (D.field "firstName" D.string)
        (D.field "middleName" (D.maybe D.string))
        (D.field "lastName" D.string)



--


formDecoder : FD.Decoder { r | firstName : String, middleName : String, lastName : String } Error Name
formDecoder =
    FD.map3 Name
        (FD.lift .firstName firstName)
        (FD.lift .middleName middleName)
        (FD.lift .lastName lastName)


firstName : FD.Decoder String Error String
firstName =
    FD.identity
        |> FD.assert FormUtils.required
        |> FD.assert FormUtils.customAlpha


middleName : FD.Decoder String Error (Maybe String)
middleName =
    FD.custom <|
        \s ->
            if s == "" then
                Ok Nothing

            else
                Ok (Just s)


lastName : FD.Decoder String Error String
lastName =
    FD.identity
        |> FD.assert FormUtils.required
        |> FD.assert FormUtils.customAlpha
