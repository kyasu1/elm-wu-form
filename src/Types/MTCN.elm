module Types.MTCN exposing (MTCN, decoder, encode, formDecoder, format, fromString, toString)

import Form.Decoder as FD
import FormUtils exposing (Error)
import Json.Decode as D
import Json.Encode as E


type MTCN
    = MTCN String


toString : MTCN -> String
toString (MTCN s) =
    s


fromString : String -> MTCN
fromString s =
    MTCN s


encode : MTCN -> E.Value
encode =
    E.string << toString


decoder : D.Decoder MTCN
decoder =
    D.string
        |> D.map MTCN


format : String -> String
format s =
    stripDash s
        |> insertDash


stripDash : String -> String
stripDash s =
    String.filter (\c -> c /= '-') s


insertDash : String -> String
insertDash s =
    if String.length s <= 3 then
        s

    else if String.length s <= 6 then
        String.left 3 s ++ "-" ++ (String.dropLeft 3 s |> String.left 3)

    else
        String.left 3 s
            ++ "-"
            ++ (String.dropLeft 3 s |> String.left 3)
            ++ "-"
            ++ String.dropLeft 6 s


formDecoder : FD.Decoder String Error MTCN
formDecoder =
    FD.identity
        |> FD.andThen
            (\s ->
                stripDash s |> FD.always
            )
        |> FD.andThen
            (\s ->
                if String.length s /= 10 then
                    if String.length s > 10 then
                        FD.fail <| FormUtils.fromString "MTCN is longer than 10 / 10文字より長いです"

                    else
                        FD.fail <| FormUtils.fromString "MTCN is less than 10 / 10文字より短いです"

                else if String.filter (not << Char.isDigit) s /= "" then
                    FD.fail <| FormUtils.fromString "MTCN must be digits / 数字で入力してください"

                else
                    FD.always <| MTCN s
            )
