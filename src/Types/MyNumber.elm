module Types.MyNumber exposing (MyNumber, decoder, encode, formDecoder, toString)

import Form.Decoder as FD
import FormUtils exposing (Error)
import Json.Decode as D
import Json.Encode as E


type MyNumber
    = MyNumber String


toString : MyNumber -> String
toString (MyNumber s) =
    s


q : List Int
q =
    [ 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 ] |> List.reverse


checkDigits : String -> Maybe String
checkDigits s =
    if String.length s /= 12 then
        Just "Must be 12 digits / 12桁で入力してください"

    else
        let
            ints =
                s
                    |> String.toList
                    |> List.filterMap (String.fromChar >> String.toInt)
        in
        if List.length ints == 12 then
            case List.reverse ints of
                check :: rest ->
                    let
                        res =
                            List.map2 (*) rest q
                                |> List.foldl (+) 0
                                |> modBy 11
                    in
                    if res <= 1 then
                        if 0 == check then
                            Nothing

                        else
                            Just "Invalid my number / 不正なマイナンバーです"

                    else if (11 - res) == check then
                        Nothing

                    else
                        Just "Invalid my number / 不正なマイナンバーです"

                _ ->
                    Just "Invalid my number / 不正なマイナンバーです"

        else
            Just "Must be 12 digits / 12桁で入力してください"


encode : MyNumber -> E.Value
encode (MyNumber raw) =
    E.string raw


decoder : D.Decoder MyNumber
decoder =
    D.string
        |> D.andThen
            (\s ->
                case checkDigits s of
                    Nothing ->
                        D.succeed s

                    Just e ->
                        D.fail e
            )
        |> D.map MyNumber


formDecoder : FD.Decoder String Error MyNumber
formDecoder =
    FD.identity
        |> FD.andThen
            (\s ->
                case checkDigits s of
                    Nothing ->
                        FD.always (MyNumber s)

                    Just e ->
                        FD.fail <| FormUtils.fromString e
            )
