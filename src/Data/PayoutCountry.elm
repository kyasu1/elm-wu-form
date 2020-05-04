module Data.PayoutCountry exposing (Code, Msg, State, decoder, default, initialState, list, selected, selector, toString, update, lookup)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onFocus, onInput)
import Json.Decode as D


type Code
    = Code String


default : Code
default =
    Code "PH_PHP"


toString : Code -> String
toString (Code s) =
    s


lookup : Code -> String
lookup c =
    List.filterMap
        (\( v, l ) ->
            if v == c then
                Just l

            else
                Nothing
        )
        list
        |> List.head
        |> Maybe.withDefault ""


decoder : D.Decoder Code
decoder =
    D.string
        |> D.andThen
            (\s ->
                case List.filter (\( Code code, _ ) -> code == s) list |> List.head of
                    Just ( v, _ ) ->
                        D.succeed v

                    Nothing ->
                        D.fail ("Invalid PayoutCountry " ++ s)
            )


list : List ( Code, String )
list =
    [ ( Code "AF_AFN", "Afghanistan - Afghanistan Afghani" )
    , ( Code "AF_USD", "Afghanistan - US Dollar" )
    , ( Code "XP_USD", "Afghanistan US Military Base - US Dollar" )
    , ( Code "AL_ALL", "Albania - Albanian Lek" )
    , ( Code "AL_EUR", "Albania - Euro" )
    , ( Code "DZ_DZD", "Algeria - Algerian Dinar" )
    , ( Code "AS_USD", "American Samoa - US Dollar" )
    , ( Code "AD_EUR", "Andorra - Euro" )
    , ( Code "AO_AOA", "Angola - Angolan Kwanza" )
    , ( Code "AI_XCD", "Anguilla - East Caribbean Dollar" )
    , ( Code "AI_USD", "Anguilla - US Dollar" )
    , ( Code "AG_XCD", "Antigua And Barbuda - East Caribbean Dollar" )
    , ( Code "AR_ARS", "Argentina - Argentine Peso" )
    , ( Code "AW_AWG", "Aruba - アルバフロリン" )
    , ( Code "AU_AUD", "Australia - Australian Dollar" )
    , ( Code "AT_EUR", "Austria - Euro" )
    , ( Code "AZ_AZN", "Azerbaijan - Azerbaijan Manat" )
    , ( Code "AZ_USD", "Azerbaijan - US Dollar" )
    , ( Code "BS_BSD", "Bahamas - Bahamian Dollar" )
    , ( Code "BH_BHD", "Bahrain - Bahraini Dinar" )
    , ( Code "BH_USD", "Bahrain - US Dollar" )
    , ( Code "XB_USD", "Bahrain US Military Base - US Dollar" )
    , ( Code "BD_BDT", "Bangladesh - Bangladeshi Taka" )
    , ( Code "BB_BBD", "Barbados - Barbados Dollar" )
    , ( Code "BY_BYN", "Belarus - Belarusian Ruble" )
    , ( Code "BY_USD", "Belarus - US Dollar" )
    , ( Code "BE_EUR", "Belgium - Euro" )
    , ( Code "QQ_USD", "Belgium US Military Base - US Dollar" )
    , ( Code "BZ_BZD", "Belize - Belize Dollar" )
    , ( Code "BJ_XOF", "Benin - CFA Franc BCEAO" )
    , ( Code "BM_USD", "Bermuda - US Dollar" )
    , ( Code "BM_BMD", "Bermuda - バミューダドル" )
    , ( Code "BT_BTN", "Bhutan - Bhutan Ngultrum" )
    , ( Code "BO_BOB", "Bolivia - Bolivian Boliviano" )
    , ( Code "BO_USD", "Bolivia - US Dollar" )
    , ( Code "BA_BAM", "Bosnia and Herzegovina - Convertible Mark" )
    , ( Code "BA_EUR", "Bosnia and Herzegovina - Euro" )
    , ( Code "BA_USD", "Bosnia and Herzegovina - US Dollar" )
    , ( Code "BW_BWP", "Botswana - Botswana Pula" )
    , ( Code "BR_BRL", "Brazil - Brazilian Real" )
    , ( Code "BR_USD", "Brazil - US Dollar" )
    , ( Code "VG_USD", "British Virgin Islands - US Dollar" )
    , ( Code "BN_BND", "Brunei Darussalam - Brunei Dollar" )
    , ( Code "BG_BGN", "Bulgaria - Bulgarian New Lev" )
    , ( Code "BG_EUR", "Bulgaria - Euro" )
    , ( Code "BF_XOF", "Burkina Faso - CFA Franc BCEAO" )
    , ( Code "BI_BIF", "Burundi - Burundi Franc" )
    , ( Code "BI_USD", "Burundi - US Dollar" )
    , ( Code "KH_USD", "Cambodia - US Dollar" )
    , ( Code "CM_XAF", "Cameroon - CFA Franc BEAC" )
    , ( Code "CA_CAD", "Canada - Canadian Dollar" )
    , ( Code "CV_CVE", "Cape Verde - Cape Verde Escudo" )
    , ( Code "KY_KYD", "Cayman Islands - Cayman Islands Dollar" )
    , ( Code "CF_XAF", "Central African Republic - CFA Franc BEAC" )
    , ( Code "TD_XAF", "Chad - CFA Franc BEAC" )
    , ( Code "CL_CLP", "Chile - Chilean Peso" )
    , ( Code "CN_CNY", "China - Chinese Yuan Renminbi" )
    , ( Code "CN_USD", "China - US Dollar" )
    , ( Code "CO_COP", "Colombia - Colombian Peso" )
    , ( Code "KM_KMF", "Comoros - Comoros Franc" )
    , ( Code "CD_USD", "Congo, Democratic Republic of - US Dollar" )
    , ( Code "CG_XAF", "Congo-Brazzaville - CFA Franc BEAC" )
    , ( Code "CK_NZD", "Cook Islands - New Zealand Dollar" )
    , ( Code "CR_CRC", "Costa Rica - Costa Rican Colon" )
    , ( Code "CR_USD", "Costa Rica - US Dollar" )
    , ( Code "HR_HRK", "Croatia - Croatian Kuna" )
    , ( Code "QS_USD", "Cuba US Military Base - US Dollar" )
    , ( Code "AN_ANG", "Curacao - Netherlands Antilles Guilder" )
    , ( Code "C2_GBP", "Cyprus (Northern) - United Kingdom Pound" )
    , ( Code "C2_USD", "Cyprus (Northern) - US Dollar" )
    , ( Code "CY_EUR", "Cyprus - Euro" )
    , ( Code "CZ_CZK", "Czech Republic - Czech Koruna" )
    , ( Code "DK_DKK", "Denmark - Danish Krone" )
    , ( Code "DJ_DJF", "Djibouti - Djibouti Franc" )
    , ( Code "DJ_USD", "Djibouti - US Dollar" )
    , ( Code "QV_USD", "Djibouti US Military Base - US Dollar" )
    , ( Code "DM_XCD", "Dominica - East Caribbean Dollar" )
    , ( Code "DO_DOP", "Dominican Republic - Dominican Peso" )
    , ( Code "TP_USD", "East Timor - US Dollar" )
    , ( Code "EC_USD", "Ecuador - US Dollar" )
    , ( Code "EG_EGP", "Egypt - Egyptian Pound" )
    , ( Code "EG_USD", "Egypt - US Dollar" )
    , ( Code "SV_USD", "El Salvador - US Dollar" )
    , ( Code "XQ_GBP", "England - United Kingdom Pound" )
    , ( Code "GQ_XAF", "Equatorial Guinea - CFA Franc BEAC" )
    , ( Code "ER_ERN", "Eritrea - Eritrean Nakfa" )
    , ( Code "EE_EUR", "Estonia - Euro" )
    , ( Code "ET_ETB", "Ethiopia - Ethiopian Birr" )
    , ( Code "ET_USD", "Ethiopia - US Dollar" )
    , ( Code "FK_FKP", "Falkland Islands (Malvinas) - Falkland Islands Pound" )
    , ( Code "FJ_FJD", "Fiji - Fiji Dollar" )
    , ( Code "FI_EUR", "Finland - Euro" )
    , ( Code "FR_EUR", "France - Euro" )
    , ( Code "GF_EUR", "French Guiana - Euro" )
    , ( Code "GA_XAF", "Gabon - CFA Franc BEAC" )
    , ( Code "GM_GMD", "Gambia - Gambian Dalasi" )
    , ( Code "GE_USD", "Georgia - US Dollar" )
    , ( Code "GE_GEL", "Georgia - ジョージアンラリ" )
    , ( Code "DE_EUR", "Germany - Euro" )
    , ( Code "QO_USD", "Germany US Military Base - US Dollar" )
    , ( Code "GH_GHS", "Ghana - Ghanaian Cedi" )
    , ( Code "GI_GBP", "Gibraltar - United Kingdom Pound" )
    , ( Code "GR_EUR", "Greece - Euro" )
    , ( Code "QZ_USD", "Greece US Military Base - US Dollar" )
    , ( Code "GD_XCD", "Grenada - East Caribbean Dollar" )
    , ( Code "GP_EUR", "Guadeloupe - Euro" )
    , ( Code "GU_USD", "Guam - US Dollar" )
    , ( Code "XY_USD", "Guam US Military Base - US Dollar" )
    , ( Code "GT_GTQ", "Guatemala - Guatemalan Quetzal" )
    , ( Code "GW_XOF", "Guinea-Bissau - CFA Franc BCEAO" )
    , ( Code "GN_GNF", "Guinea - Guinea Franc" )
    , ( Code "GY_GYD", "Guyana - Guyana Dollar" )
    , ( Code "HT_USD", "Haiti - US Dollar" )
    , ( Code "HN_HNL", "Honduras - Honduran Lempira" )
    , ( Code "QR_USD", "Honduras US Military Base - US Dollar" )
    , ( Code "HK_HKD", "Hong Kong - Hong Kong Dollar" )
    , ( Code "HK_USD", "Hong Kong - US Dollar" )
    , ( Code "HU_HUF", "Hungary - Hungarian Forint" )
    , ( Code "IS_EUR", "Iceland - Euro" )
    , ( Code "IS_ISK", "Iceland - Iceland Krona" )
    , ( Code "IN_INR", "India - Indian Rupee" )
    , ( Code "ID_IDR", "Indonesia - Indonesian Rupiah" )
    , ( Code "IQ_IQD", "Iraq - Iraqi Dinar" )
    , ( Code "IQ_USD", "Iraq - US Dollar" )
    , ( Code "QX_USD", "Iraq US Military Base - US Dollar" )
    , ( Code "IE_EUR", "Ireland - Euro" )
    , ( Code "IL_ILS", "Israel - Israeli New Shekel" )
    , ( Code "IL_USD", "Israel - US Dollar" )
    , ( Code "IT_EUR", "Italy - Euro" )
    , ( Code "QP_USD", "Italy US Military Base - US Dollar" )
    , ( Code "CI_XOF", "Ivory Coast - CFA Franc BCEAO" )
    , ( Code "JM_JMD", "Jamaica - Jamaican Dollar" )
    , ( Code "JP_JPY", "Japan - Japanese Yen" )
    , ( Code "QM_USD", "Japan US Military Base - US Dollar" )
    , ( Code "JO_JOD", "Jordan - Jordanian Dinar" )
    , ( Code "KZ_KZT", "Kazakhstan - Kazakhstan Tenge" )
    , ( Code "KZ_USD", "Kazakhstan - US Dollar" )
    , ( Code "KE_KES", "Kenya - Kenyan Shilling" )
    , ( Code "KI_AUD", "Kiribati - Australian Dollar" )
    , ( Code "KR_USD", "Korea - US Dollar" )
    , ( Code "QN_USD", "Korea US Military Base - US Dollar" )
    , ( Code "K1_EUR", "Kosovo - Euro" )
    , ( Code "XF_USD", "Kosovo US Military Base - US Dollar" )
    , ( Code "KW_KWD", "Kuwait - Kuwaiti Dinar" )
    , ( Code "QU_USD", "Kuwait US Military Base - US Dollar" )
    , ( Code "KG_KGS", "Kyrghyz Republic - Kyrgyzstani Som" )
    , ( Code "KG_USD", "Kyrghyz Republic - US Dollar" )
    , ( Code "LA_LAK", "Laos - Laos Kip" )
    , ( Code "LV_EUR", "Latvia - Euro" )
    , ( Code "LV_USD", "Latvia - US Dollar" )
    , ( Code "LB_USD", "Lebanon - US Dollar" )
    , ( Code "LS_USD", "Lesotho - US Dollar" )
    , ( Code "LR_USD", "Liberia - US Dollar" )
    , ( Code "LY_LYD", "Libya - Libyan Dinar" )
    , ( Code "LI_CHF", "Liechtenstein - Swiss Franc" )
    , ( Code "LT_EUR", "Lithuania - Euro" )
    , ( Code "LU_EUR", "Luxembourg - Euro" )
    , ( Code "MO_MOP", "Macau - Macau Pataca" )
    , ( Code "MK_EUR", "Macedonia - Euro" )
    , ( Code "MK_USD", "Macedonia - US Dollar" )
    , ( Code "MK_MKD", "Macedonia - マケドニアデナール" )
    , ( Code "MG_MGA", "Madagascar - Malagasy Ariary" )
    , ( Code "MW_MWK", "Malawi - Malawi Kwacha" )
    , ( Code "MY_MYR", "Malaysia - Malaysian Ringgit" )
    , ( Code "MV_MVR", "Maldives - Maldive Rufiyaa" )
    , ( Code "MV_USD", "Maldives - US Dollar" )
    , ( Code "ML_XOF", "Mali - CFA Franc BCEAO" )
    , ( Code "MT_EUR", "Malta - Euro" )
    , ( Code "MH_USD", "Marshall Islands - US Dollar" )
    , ( Code "MQ_EUR", "Martinique - Euro" )
    , ( Code "MR_MRU", "Mauritania - ウギア" )
    , ( Code "MU_MUR", "Mauritius - Mauritius Rupee" )
    , ( Code "YT_EUR", "Mayotte - Euro" )
    , ( Code "MX_MXN", "Mexico - Mexican Peso" )
    , ( Code "FM_USD", "Micronesia - US Dollar" )
    , ( Code "MD_EUR", "Moldova - Euro" )
    , ( Code "MD_MDL", "Moldova - Moldovan Leu" )
    , ( Code "MD_USD", "Moldova - US Dollar" )
    , ( Code "MC_EUR", "Monaco - Euro" )
    , ( Code "MN_MNT", "Mongolia - Mongolian Tugrik" )
    , ( Code "MN_USD", "Mongolia - US Dollar" )
    , ( Code "ME_EUR", "Montenegro - Euro" )
    , ( Code "MS_XCD", "Montserrat - East Caribbean Dollar" )
    , ( Code "MA_MAD", "Morocco - Moroccan Dirham" )
    , ( Code "MZ_MZN", "Mozambique - Mozambique New Metical" )
    , ( Code "MM_MMK", "Myanmar - Kyat" )
    , ( Code "NA_USD", "Namibia - US Dollar" )
    , ( Code "NR_AUD", "Nauru - Australian Dollar" )
    , ( Code "NP_NPR", "Nepal - Nepalese Rupee" )
    , ( Code "NL_EUR", "Netherlands - Euro" )
    , ( Code "QT_USD", "Netherlands US Military Base - US Dollar" )
    , ( Code "NZ_NZD", "New Zealand - New Zealand Dollar" )
    , ( Code "NI_USD", "Nicaragua - US Dollar" )
    , ( Code "NE_XOF", "Niger - CFA Franc BCEAO" )
    , ( Code "NG_NGN", "Nigeria - Nigerian Naira" )
    , ( Code "NU_NZD", "Niue - New Zealand Dollar" )
    , ( Code "MP_USD", "Northern Mariana Islands - US Dollar" )
    , ( Code "XZ_GBP", "North Ireland - United Kingdom Pound" )
    , ( Code "NO_NOK", "Norway - Norwegian Krone" )
    , ( Code "OM_OMR", "Oman - Omani Rial" )
    , ( Code "OM_USD", "Oman - US Dollar" )
    , ( Code "PK_PKR", "Pakistan - Pakistan Rupee" )
    , ( Code "PW_USD", "Palau - US Dollar" )
    , ( Code "PS_ILS", "Palestinian Authority - Israeli New Shekel" )
    , ( Code "PS_JOD", "Palestinian Authority - Jordanian Dinar" )
    , ( Code "PS_USD", "Palestinian Authority - US Dollar" )
    , ( Code "PA_USD", "Panama - US Dollar" )
    , ( Code "PG_PGK", "Papua New Guinea - Papua New Guinea Kina" )
    , ( Code "PY_PYG", "Paraguay - Paraguay Guarani" )
    , ( Code "PY_USD", "Paraguay - US Dollar" )
    , ( Code "PE_USD", "Peru - US Dollar" )
    , ( Code "PE_PEN", "Peru - ソル（Sol）" )
    , ( Code "PH_PHP", "Philippines - Philippine Peso" )
    , ( Code "PH_USD", "Philippines - US Dollar" )
    , ( Code "PL_PLN", "Poland - Polish Zloty" )
    , ( Code "PT_EUR", "Portugal - Euro" )
    , ( Code "XT_USD", "Portugal US Military Base - US Dollar" )
    , ( Code "PR_USD", "Puerto Rico - US Dollar" )
    , ( Code "QA_QAR", "Qatar - Qatari Rial" )
    , ( Code "QY_USD", "Qatar US Military Base - US Dollar" )
    , ( Code "RE_EUR", "Reunion Island - Euro" )
    , ( Code "RO_EUR", "Romania - Euro" )
    , ( Code "RO_RON", "Romania - Romanian New Leu" )
    , ( Code "XW_USD", "Rota, CNMI - US Dollar" )
    , ( Code "RU_RUB", "Russia - Russian Rouble" )
    , ( Code "RU_USD", "Russia - US Dollar" )
    , ( Code "RW_RWF", "Rwanda - Rwanda Franc" )
    , ( Code "RW_USD", "Rwanda - US Dollar" )
    , ( Code "BL_EUR", "Saint Barthelemy - Euro" )
    , ( Code "KN_XCD", "Saint Kitts And Nevis - East Caribbean Dollar" )
    , ( Code "KN_USD", "Saint Kitts And Nevis - US Dollar" )
    , ( Code "LC_XCD", "Saint Lucia - East Caribbean Dollar" )
    , ( Code "VC_XCD", "Saint Vincent And The Grenadines - East Caribbean Dollar" )
    , ( Code "XU_USD", "Saipan, CNMI - US Dollar" )
    , ( Code "WS_WST", "Samoa - Samoan Tala" )
    , ( Code "ST_STN", "Sao Tome And Principe - Sao Tome ニュードブラ" )
    , ( Code "SA_SAR", "Saudi Arabia - Saudi Riyal" )
    , ( Code "XS_GBP", "Scotland - United Kingdom Pound" )
    , ( Code "SN_XOF", "Senegal - CFA Franc BCEAO" )
    , ( Code "YU_EUR", "Serbia - Euro" )
    , ( Code "YU_RSD", "Serbia - Serbian Dinar" )
    , ( Code "SC_SCR", "Seychelles - Seychelles Rupee" )
    , ( Code "SL_SLL", "Sierra Leone - Sierra Leone Leone" )
    , ( Code "SG_SGD", "Singapore - Singapore Dollar" )
    , ( Code "SK_EUR", "Slovakia - Euro" )
    , ( Code "SI_EUR", "Slovenia - Euro" )
    , ( Code "SB_SBD", "Solomon Islands - Solomon Islands Dollar" )
    , ( Code "XA_USD", "Somaliland - US Dollar" )
    , ( Code "ZA_USD", "South Africa - US Dollar" )
    , ( Code "SS_SSP", "South Sudan - South Sudanese Pound" )
    , ( Code "SS_USD", "South Sudan - US Dollar" )
    , ( Code "ES_EUR", "Spain - Euro" )
    , ( Code "AB_USD", "Spain US Military Base - US Dollar" )
    , ( Code "LK_LKR", "Sri Lanka - Sri Lanka Rupee" )
    , ( Code "S1_ANG", "St. Maarten - Netherlands Antilles Guilder" )
    , ( Code "S1_USD", "St. Maarten - US Dollar" )
    , ( Code "MF_EUR", "St. Martin - Euro" )
    , ( Code "MF_USD", "St. Martin - US Dollar" )
    , ( Code "XD_USD", "St. Thomas - US Dollar" )
    , ( Code "SD_SDG", "Sudan - Sudan Pound" )
    , ( Code "SR_EUR", "Suriname - Euro" )
    , ( Code "SR_USD", "Suriname - US Dollar" )
    , ( Code "SZ_USD", "Swaziland - US Dollar" )
    , ( Code "SE_SEK", "Sweden - Swedish Krona" )
    , ( Code "CH_CHF", "Switzerland - Swiss Franc" )
    , ( Code "SY_SYP", "Syria - Syrian Pound" )
    , ( Code "TW_USD", "Taiwan - US Dollar" )
    , ( Code "TJ_USD", "Tajikistan - US Dollar" )
    , ( Code "TZ_TZS", "Tanzania - Tanzanian Shilling" )
    , ( Code "TH_THB", "Thailand - Thai Baht" )
    , ( Code "XV_USD", "Tinian, CNMI - US Dollar" )
    , ( Code "TG_XOF", "Togo - CFA Franc BCEAO" )
    , ( Code "TO_TOP", "Tonga - Tongan Pa'anga" )
    , ( Code "TT_TTD", "Trinidad and Tobago - Trinidad/Tobago Dollar" )
    , ( Code "TN_TND", "Tunisia - Tunisian Dinar" )
    , ( Code "TR_EUR", "Turkey - Euro" )
    , ( Code "TR_TRY", "Turkey - Turkish Lira" )
    , ( Code "TR_USD", "Turkey - US Dollar" )
    , ( Code "XN_USD", "Turkey US Military Base - US Dollar" )
    , ( Code "TM_USD", "Turkmenistan - US Dollar" )
    , ( Code "TC_USD", "Turks and Caicos Islands - US Dollar" )
    , ( Code "TV_AUD", "Tuvalu - Australian Dollar" )
    , ( Code "XE_USD", "UAE US Military Base - US Dollar" )
    , ( Code "UG_UGX", "Uganda - Uganda Shilling" )
    , ( Code "UA_UAH", "Ukraine - Ukraine Hryvnia" )
    , ( Code "UA_USD", "Ukraine - US Dollar" )
    , ( Code "AE_AED", "United Arab Emirates - Utd. Arab Emir. Dirham" )
    , ( Code "GB_GBP", "United Kingdom - United Kingdom Pound" )
    , ( Code "QW_USD", "United Kingdom US Military Base - US Dollar" )
    , ( Code "US_USD", "United States - US Dollar" )
    , ( Code "UY_UYU", "Uruguay - Peso Uruguayo" )
    , ( Code "UY_USD", "Uruguay - US Dollar" )
    , ( Code "UZ_USD", "Uzbekistan - US Dollar" )
    , ( Code "VU_VUV", "Vanuatu - Vanuatu Vatu" )
    , ( Code "VE_VIB", "Venezuela - VIB - ボリーバルフエルテ" )
    , ( Code "VN_USD", "Vietnam - US Dollar" )
    , ( Code "VN_VND", "Vietnam - Vietnamese Dong" )
    , ( Code "VI_USD", "Virgin Islands (US) - US Dollar" )
    , ( Code "XR_GBP", "Wales - United Kingdom Pound" )
    , ( Code "YE_USD", "Yemen - US Dollar" )
    , ( Code "ZM_ZMW", "Zambia - New Kwacha" )
    , ( Code "ZW_USD", "Zimbabwe - US Dollar" )
    ]



--


type State
    = Empty
    | Open String
    | Closed ( Code, String )


initialState : Code -> State
initialState code =
    case List.filter (\( c, _ ) -> c == code) list |> List.head of
        Just ( c, l ) ->
            Closed ( c, l )

        Nothing ->
            Empty


selected : State -> Maybe ( Code, String )
selected state =
    case state of
        Closed ( code, label ) ->
            Just ( code, label )

        _ ->
            Nothing


type Msg
    = HandleInput String
    | HandleEnter
    | HandleSelect ( Code, String )


update : Msg -> State -> State
update msg state =
    case state of
        Empty ->
            case msg of
                HandleEnter ->
                    Open ""

                _ ->
                    state

        Open _ ->
            case msg of
                HandleInput s ->
                    Open s

                HandleSelect picked ->
                    Closed picked

                _ ->
                    state

        Closed ( _, label ) ->
            case msg of
                HandleInput s ->
                    Open s

                HandleEnter ->
                    Open label

                _ ->
                    state


filtered : String -> List ( Code, String )
filtered q =
    q
        |> String.toLower
        |> String.trim
        |> (\sanitized ->
                if q == "" then
                    []

                else
                    List.filter (\( Code code, label ) -> String.contains sanitized (String.toLower label) || String.contains sanitized (String.toLower code)) list
           )

inputClass : Html.Attribute msg
inputClass =
    class "border px-2 py-1 w-full"


selector :
    State
    -> Html Msg
selector state =
    label [ class "block px-2 py-2 w-full" ]
        [ div [ class "text-xs px-2" ] [ text "Currency（通貨）" ]
        , div [ class "relative" ]
            [ case state of
                Empty ->
                    input [ value "", onFocus HandleEnter, inputClass ] []

                Closed ( _, label ) ->
                    input [ value label, onInput HandleInput, inputClass ] []

                Open v ->
                    input [ value v, onInput HandleInput, inputClass ] []
            , case state of
                Open v ->
                    div [ class "absolute left-0 mt-2 w-full rounded-md shadow-lg" ]
                        [ div [ class "rounded-md bg-white shadow-xs overflw-y-scroll" ] <| List.map optionItem (filtered v)
                        ]

                _ ->
                    text ""
            ]
        ]


optionItem : ( Code, String ) -> Html Msg
optionItem ( code, label ) =
    option
        [ class "block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900 cursor-pointer"
        , value label
        , onClick (HandleSelect ( code, label ))
        ]
        [ text label ]
