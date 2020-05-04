module Data.PayoutCountry exposing (Code, Msg, State, decoder, default, initialState, list, selected, selector, toString, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onFocus, onInput)
import Json.Decode as D


type Code
    = AF_AFN
    | AF_USD
    | XP_USD
    | AL_ALL
    | AL_EUR
    | DZ_DZD
    | AS_USD
    | AD_EUR
    | AO_AOA
    | AI_XCD
    | AI_USD
    | AG_XCD
    | AR_ARS
    | AW_AWG
    | AU_AUD
    | AT_EUR
    | AZ_AZN
    | AZ_USD
    | BS_BSD
    | BH_BHD
    | BH_USD
    | XB_USD
    | BD_BDT
    | BB_BBD
    | BY_BYN
    | BY_USD
    | BE_EUR
    | QQ_USD
    | BZ_BZD
    | BJ_XOF
    | BM_USD
    | BM_BMD
    | BT_BTN
    | BO_BOB
    | BO_USD
    | BA_BAM
    | BA_EUR
    | BA_USD
    | BW_BWP
    | BR_BRL
    | BR_USD
    | VG_USD
    | BN_BND
    | BG_BGN
    | BG_EUR
    | BF_XOF
    | BI_BIF
    | BI_USD
    | KH_USD
    | CM_XAF
    | CA_CAD
    | CV_CVE
    | KY_KYD
    | CF_XAF
    | TD_XAF
    | CL_CLP
    | CN_CNY
    | CN_USD
    | CO_COP
    | KM_KMF
    | CD_USD
    | CG_XAF
    | CK_NZD
    | CR_CRC
    | CR_USD
    | HR_HRK
    | QS_USD
    | AN_ANG
    | C2_GBP
    | C2_USD
    | CY_EUR
    | CZ_CZK
    | DK_DKK
    | DJ_DJF
    | DJ_USD
    | QV_USD
    | DM_XCD
    | DO_DOP
    | TP_USD
    | EC_USD
    | EG_EGP
    | EG_USD
    | SV_USD
    | XQ_GBP
    | GQ_XAF
    | ER_ERN
    | EE_EUR
    | ET_ETB
    | ET_USD
    | FK_FKP
    | FJ_FJD
    | FI_EUR
    | FR_EUR
    | GF_EUR
    | GA_XAF
    | GM_GMD
    | GE_USD
    | GE_GEL
    | DE_EUR
    | QO_USD
    | GH_GHS
    | GI_GBP
    | GR_EUR
    | QZ_USD
    | GD_XCD
    | GP_EUR
    | GU_USD
    | XY_USD
    | GT_GTQ
    | GW_XOF
    | GN_GNF
    | GY_GYD
    | HT_USD
    | HN_HNL
    | QR_USD
    | HK_HKD
    | HK_USD
    | HU_HUF
    | IS_EUR
    | IS_ISK
    | IN_INR
    | ID_IDR
    | IQ_IQD
    | IQ_USD
    | QX_USD
    | IE_EUR
    | IL_ILS
    | IL_USD
    | IT_EUR
    | QP_USD
    | CI_XOF
    | JM_JMD
    | JP_JPY
    | QM_USD
    | JO_JOD
    | KZ_KZT
    | KZ_USD
    | KE_KES
    | KI_AUD
    | KR_USD
    | QN_USD
    | K1_EUR
    | XF_USD
    | KW_KWD
    | QU_USD
    | KG_KGS
    | KG_USD
    | LA_LAK
    | LV_EUR
    | LV_USD
    | LB_USD
    | LS_USD
    | LR_USD
    | LY_LYD
    | LI_CHF
    | LT_EUR
    | LU_EUR
    | MO_MOP
    | MK_EUR
    | MK_USD
    | MK_MKD
    | MG_MGA
    | MW_MWK
    | MY_MYR
    | MV_MVR
    | MV_USD
    | ML_XOF
    | MT_EUR
    | MH_USD
    | MQ_EUR
    | MR_MRU
    | MU_MUR
    | YT_EUR
    | MX_MXN
    | FM_USD
    | MD_EUR
    | MD_MDL
    | MD_USD
    | MC_EUR
    | MN_MNT
    | MN_USD
    | ME_EUR
    | MS_XCD
    | MA_MAD
    | MZ_MZN
    | MM_MMK
    | NA_USD
    | NR_AUD
    | NP_NPR
    | NL_EUR
    | QT_USD
    | NZ_NZD
    | NI_USD
    | NE_XOF
    | NG_NGN
    | NU_NZD
    | MP_USD
    | XZ_GBP
    | NO_NOK
    | OM_OMR
    | OM_USD
    | PK_PKR
    | PW_USD
    | PS_ILS
    | PS_JOD
    | PS_USD
    | PA_USD
    | PG_PGK
    | PY_PYG
    | PY_USD
    | PE_USD
    | PE_PEN
    | PH_PHP
    | PH_USD
    | PL_PLN
    | PT_EUR
    | XT_USD
    | PR_USD
    | QA_QAR
    | QY_USD
    | RE_EUR
    | RO_EUR
    | RO_RON
    | XW_USD
    | RU_RUB
    | RU_USD
    | RW_RWF
    | RW_USD
    | BL_EUR
    | KN_XCD
    | KN_USD
    | LC_XCD
    | VC_XCD
    | XU_USD
    | WS_WST
    | ST_STN
    | SA_SAR
    | XS_GBP
    | SN_XOF
    | YU_EUR
    | YU_RSD
    | SC_SCR
    | SL_SLL
    | SG_SGD
    | SK_EUR
    | SI_EUR
    | SB_SBD
    | XA_USD
    | ZA_USD
    | SS_SSP
    | SS_USD
    | ES_EUR
    | AB_USD
    | LK_LKR
    | S1_ANG
    | S1_USD
    | MF_EUR
    | MF_USD
    | XD_USD
    | SD_SDG
    | SR_EUR
    | SR_USD
    | SZ_USD
    | SE_SEK
    | CH_CHF
    | SY_SYP
    | TW_USD
    | TJ_USD
    | TZ_TZS
    | TH_THB
    | XV_USD
    | TG_XOF
    | TO_TOP
    | TT_TTD
    | TN_TND
    | TR_EUR
    | TR_TRY
    | TR_USD
    | XN_USD
    | TM_USD
    | TC_USD
    | TV_AUD
    | XE_USD
    | UG_UGX
    | UA_UAH
    | UA_USD
    | AE_AED
    | GB_GBP
    | QW_USD
    | US_USD
    | UY_UYU
    | UY_USD
    | UZ_USD
    | VU_VUV
    | VE_VIB
    | VN_USD
    | VN_VND
    | VI_USD
    | XR_GBP
    | YE_USD
    | ZM_ZMW
    | ZW_USD


default : Code
default =
    PH_PHP


toString : Code -> String
toString c =
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
                case List.filter (\( _, l ) -> l == s) list |> List.head of
                    Just ( v, _ ) ->
                        D.succeed v

                    Nothing ->
                        D.fail ("Invalid PayoutCountry " ++ s)
            )


list : List ( Code, String )
list =
    [ ( AF_AFN, "Afghanistan - Afghanistan Afghani" )
    , ( AF_USD, "Afghanistan - US Dollar" )
    , ( XP_USD, "Afghanistan US Military Base - US Dollar" )
    , ( AL_ALL, "Albania - Albanian Lek" )
    , ( AL_EUR, "Albania - Euro" )
    , ( DZ_DZD, "Algeria - Algerian Dinar" )
    , ( AS_USD, "American Samoa - US Dollar" )
    , ( AD_EUR, "Andorra - Euro" )
    , ( AO_AOA, "Angola - Angolan Kwanza" )
    , ( AI_XCD, "Anguilla - East Caribbean Dollar" )
    , ( AI_USD, "Anguilla - US Dollar" )
    , ( AG_XCD, "Antigua And Barbuda - East Caribbean Dollar" )
    , ( AR_ARS, "Argentina - Argentine Peso" )
    , ( AW_AWG, "Aruba - アルバフロリン" )
    , ( AU_AUD, "Australia - Australian Dollar" )
    , ( AT_EUR, "Austria - Euro" )
    , ( AZ_AZN, "Azerbaijan - Azerbaijan Manat" )
    , ( AZ_USD, "Azerbaijan - US Dollar" )
    , ( BS_BSD, "Bahamas - Bahamian Dollar" )
    , ( BH_BHD, "Bahrain - Bahraini Dinar" )
    , ( BH_USD, "Bahrain - US Dollar" )
    , ( XB_USD, "Bahrain US Military Base - US Dollar" )
    , ( BD_BDT, "Bangladesh - Bangladeshi Taka" )
    , ( BB_BBD, "Barbados - Barbados Dollar" )
    , ( BY_BYN, "Belarus - Belarusian Ruble" )
    , ( BY_USD, "Belarus - US Dollar" )
    , ( BE_EUR, "Belgium - Euro" )
    , ( QQ_USD, "Belgium US Military Base - US Dollar" )
    , ( BZ_BZD, "Belize - Belize Dollar" )
    , ( BJ_XOF, "Benin - CFA Franc BCEAO" )
    , ( BM_USD, "Bermuda - US Dollar" )
    , ( BM_BMD, "Bermuda - バミューダドル" )
    , ( BT_BTN, "Bhutan - Bhutan Ngultrum" )
    , ( BO_BOB, "Bolivia - Bolivian Boliviano" )
    , ( BO_USD, "Bolivia - US Dollar" )
    , ( BA_BAM, "Bosnia and Herzegovina - Convertible Mark" )
    , ( BA_EUR, "Bosnia and Herzegovina - Euro" )
    , ( BA_USD, "Bosnia and Herzegovina - US Dollar" )
    , ( BW_BWP, "Botswana - Botswana Pula" )
    , ( BR_BRL, "Brazil - Brazilian Real" )
    , ( BR_USD, "Brazil - US Dollar" )
    , ( VG_USD, "British Virgin Islands - US Dollar" )
    , ( BN_BND, "Brunei Darussalam - Brunei Dollar" )
    , ( BG_BGN, "Bulgaria - Bulgarian New Lev" )
    , ( BG_EUR, "Bulgaria - Euro" )
    , ( BF_XOF, "Burkina Faso - CFA Franc BCEAO" )
    , ( BI_BIF, "Burundi - Burundi Franc" )
    , ( BI_USD, "Burundi - US Dollar" )
    , ( KH_USD, "Cambodia - US Dollar" )
    , ( CM_XAF, "Cameroon - CFA Franc BEAC" )
    , ( CA_CAD, "Canada - Canadian Dollar" )
    , ( CV_CVE, "Cape Verde - Cape Verde Escudo" )
    , ( KY_KYD, "Cayman Islands - Cayman Islands Dollar" )
    , ( CF_XAF, "Central African Republic - CFA Franc BEAC" )
    , ( TD_XAF, "Chad - CFA Franc BEAC" )
    , ( CL_CLP, "Chile - Chilean Peso" )
    , ( CN_CNY, "China - Chinese Yuan Renminbi" )
    , ( CN_USD, "China - US Dollar" )
    , ( CO_COP, "Colombia - Colombian Peso" )
    , ( KM_KMF, "Comoros - Comoros Franc" )
    , ( CD_USD, "Congo, Democratic Republic of - US Dollar" )
    , ( CG_XAF, "Congo-Brazzaville - CFA Franc BEAC" )
    , ( CK_NZD, "Cook Islands - New Zealand Dollar" )
    , ( CR_CRC, "Costa Rica - Costa Rican Colon" )
    , ( CR_USD, "Costa Rica - US Dollar" )
    , ( HR_HRK, "Croatia - Croatian Kuna" )
    , ( QS_USD, "Cuba US Military Base - US Dollar" )
    , ( AN_ANG, "Curacao - Netherlands Antilles Guilder" )
    , ( C2_GBP, "Cyprus (Northern) - United Kingdom Pound" )
    , ( C2_USD, "Cyprus (Northern) - US Dollar" )
    , ( CY_EUR, "Cyprus - Euro" )
    , ( CZ_CZK, "Czech Republic - Czech Koruna" )
    , ( DK_DKK, "Denmark - Danish Krone" )
    , ( DJ_DJF, "Djibouti - Djibouti Franc" )
    , ( DJ_USD, "Djibouti - US Dollar" )
    , ( QV_USD, "Djibouti US Military Base - US Dollar" )
    , ( DM_XCD, "Dominica - East Caribbean Dollar" )
    , ( DO_DOP, "Dominican Republic - Dominican Peso" )
    , ( TP_USD, "East Timor - US Dollar" )
    , ( EC_USD, "Ecuador - US Dollar" )
    , ( EG_EGP, "Egypt - Egyptian Pound" )
    , ( EG_USD, "Egypt - US Dollar" )
    , ( SV_USD, "El Salvador - US Dollar" )
    , ( XQ_GBP, "England - United Kingdom Pound" )
    , ( GQ_XAF, "Equatorial Guinea - CFA Franc BEAC" )
    , ( ER_ERN, "Eritrea - Eritrean Nakfa" )
    , ( EE_EUR, "Estonia - Euro" )
    , ( ET_ETB, "Ethiopia - Ethiopian Birr" )
    , ( ET_USD, "Ethiopia - US Dollar" )
    , ( FK_FKP, "Falkland Islands (Malvinas) - Falkland Islands Pound" )
    , ( FJ_FJD, "Fiji - Fiji Dollar" )
    , ( FI_EUR, "Finland - Euro" )
    , ( FR_EUR, "France - Euro" )
    , ( GF_EUR, "French Guiana - Euro" )
    , ( GA_XAF, "Gabon - CFA Franc BEAC" )
    , ( GM_GMD, "Gambia - Gambian Dalasi" )
    , ( GE_USD, "Georgia - US Dollar" )
    , ( GE_GEL, "Georgia - ジョージアンラリ" )
    , ( DE_EUR, "Germany - Euro" )
    , ( QO_USD, "Germany US Military Base - US Dollar" )
    , ( GH_GHS, "Ghana - Ghanaian Cedi" )
    , ( GI_GBP, "Gibraltar - United Kingdom Pound" )
    , ( GR_EUR, "Greece - Euro" )
    , ( QZ_USD, "Greece US Military Base - US Dollar" )
    , ( GD_XCD, "Grenada - East Caribbean Dollar" )
    , ( GP_EUR, "Guadeloupe - Euro" )
    , ( GU_USD, "Guam - US Dollar" )
    , ( XY_USD, "Guam US Military Base - US Dollar" )
    , ( GT_GTQ, "Guatemala - Guatemalan Quetzal" )
    , ( GW_XOF, "Guinea-Bissau - CFA Franc BCEAO" )
    , ( GN_GNF, "Guinea - Guinea Franc" )
    , ( GY_GYD, "Guyana - Guyana Dollar" )
    , ( HT_USD, "Haiti - US Dollar" )
    , ( HN_HNL, "Honduras - Honduran Lempira" )
    , ( QR_USD, "Honduras US Military Base - US Dollar" )
    , ( HK_HKD, "Hong Kong - Hong Kong Dollar" )
    , ( HK_USD, "Hong Kong - US Dollar" )
    , ( HU_HUF, "Hungary - Hungarian Forint" )
    , ( IS_EUR, "Iceland - Euro" )
    , ( IS_ISK, "Iceland - Iceland Krona" )
    , ( IN_INR, "India - Indian Rupee" )
    , ( ID_IDR, "Indonesia - Indonesian Rupiah" )
    , ( IQ_IQD, "Iraq - Iraqi Dinar" )
    , ( IQ_USD, "Iraq - US Dollar" )
    , ( QX_USD, "Iraq US Military Base - US Dollar" )
    , ( IE_EUR, "Ireland - Euro" )
    , ( IL_ILS, "Israel - Israeli New Shekel" )
    , ( IL_USD, "Israel - US Dollar" )
    , ( IT_EUR, "Italy - Euro" )
    , ( QP_USD, "Italy US Military Base - US Dollar" )
    , ( CI_XOF, "Ivory Coast - CFA Franc BCEAO" )
    , ( JM_JMD, "Jamaica - Jamaican Dollar" )
    , ( JP_JPY, "Japan - Japanese Yen" )
    , ( QM_USD, "Japan US Military Base - US Dollar" )
    , ( JO_JOD, "Jordan - Jordanian Dinar" )
    , ( KZ_KZT, "Kazakhstan - Kazakhstan Tenge" )
    , ( KZ_USD, "Kazakhstan - US Dollar" )
    , ( KE_KES, "Kenya - Kenyan Shilling" )
    , ( KI_AUD, "Kiribati - Australian Dollar" )
    , ( KR_USD, "Korea - US Dollar" )
    , ( QN_USD, "Korea US Military Base - US Dollar" )
    , ( K1_EUR, "Kosovo - Euro" )
    , ( XF_USD, "Kosovo US Military Base - US Dollar" )
    , ( KW_KWD, "Kuwait - Kuwaiti Dinar" )
    , ( QU_USD, "Kuwait US Military Base - US Dollar" )
    , ( KG_KGS, "Kyrghyz Republic - Kyrgyzstani Som" )
    , ( KG_USD, "Kyrghyz Republic - US Dollar" )
    , ( LA_LAK, "Laos - Laos Kip" )
    , ( LV_EUR, "Latvia - Euro" )
    , ( LV_USD, "Latvia - US Dollar" )
    , ( LB_USD, "Lebanon - US Dollar" )
    , ( LS_USD, "Lesotho - US Dollar" )
    , ( LR_USD, "Liberia - US Dollar" )
    , ( LY_LYD, "Libya - Libyan Dinar" )
    , ( LI_CHF, "Liechtenstein - Swiss Franc" )
    , ( LT_EUR, "Lithuania - Euro" )
    , ( LU_EUR, "Luxembourg - Euro" )
    , ( MO_MOP, "Macau - Macau Pataca" )
    , ( MK_EUR, "Macedonia - Euro" )
    , ( MK_USD, "Macedonia - US Dollar" )
    , ( MK_MKD, "Macedonia - マケドニアデナール" )
    , ( MG_MGA, "Madagascar - Malagasy Ariary" )
    , ( MW_MWK, "Malawi - Malawi Kwacha" )
    , ( MY_MYR, "Malaysia - Malaysian Ringgit" )
    , ( MV_MVR, "Maldives - Maldive Rufiyaa" )
    , ( MV_USD, "Maldives - US Dollar" )
    , ( ML_XOF, "Mali - CFA Franc BCEAO" )
    , ( MT_EUR, "Malta - Euro" )
    , ( MH_USD, "Marshall Islands - US Dollar" )
    , ( MQ_EUR, "Martinique - Euro" )
    , ( MR_MRU, "Mauritania - ウギア" )
    , ( MU_MUR, "Mauritius - Mauritius Rupee" )
    , ( YT_EUR, "Mayotte - Euro" )
    , ( MX_MXN, "Mexico - Mexican Peso" )
    , ( FM_USD, "Micronesia - US Dollar" )
    , ( MD_EUR, "Moldova - Euro" )
    , ( MD_MDL, "Moldova - Moldovan Leu" )
    , ( MD_USD, "Moldova - US Dollar" )
    , ( MC_EUR, "Monaco - Euro" )
    , ( MN_MNT, "Mongolia - Mongolian Tugrik" )
    , ( MN_USD, "Mongolia - US Dollar" )
    , ( ME_EUR, "Montenegro - Euro" )
    , ( MS_XCD, "Montserrat - East Caribbean Dollar" )
    , ( MA_MAD, "Morocco - Moroccan Dirham" )
    , ( MZ_MZN, "Mozambique - Mozambique New Metical" )
    , ( MM_MMK, "Myanmar - Kyat" )
    , ( NA_USD, "Namibia - US Dollar" )
    , ( NR_AUD, "Nauru - Australian Dollar" )
    , ( NP_NPR, "Nepal - Nepalese Rupee" )
    , ( NL_EUR, "Netherlands - Euro" )
    , ( QT_USD, "Netherlands US Military Base - US Dollar" )
    , ( NZ_NZD, "New Zealand - New Zealand Dollar" )
    , ( NI_USD, "Nicaragua - US Dollar" )
    , ( NE_XOF, "Niger - CFA Franc BCEAO" )
    , ( NG_NGN, "Nigeria - Nigerian Naira" )
    , ( NU_NZD, "Niue - New Zealand Dollar" )
    , ( MP_USD, "Northern Mariana Islands - US Dollar" )
    , ( XZ_GBP, "North Ireland - United Kingdom Pound" )
    , ( NO_NOK, "Norway - Norwegian Krone" )
    , ( OM_OMR, "Oman - Omani Rial" )
    , ( OM_USD, "Oman - US Dollar" )
    , ( PK_PKR, "Pakistan - Pakistan Rupee" )
    , ( PW_USD, "Palau - US Dollar" )
    , ( PS_ILS, "Palestinian Authority - Israeli New Shekel" )
    , ( PS_JOD, "Palestinian Authority - Jordanian Dinar" )
    , ( PS_USD, "Palestinian Authority - US Dollar" )
    , ( PA_USD, "Panama - US Dollar" )
    , ( PG_PGK, "Papua New Guinea - Papua New Guinea Kina" )
    , ( PY_PYG, "Paraguay - Paraguay Guarani" )
    , ( PY_USD, "Paraguay - US Dollar" )
    , ( PE_USD, "Peru - US Dollar" )
    , ( PE_PEN, "Peru - ソル（Sol）" )
    , ( PH_PHP, "Philippines - Philippine Peso" )
    , ( PH_USD, "Philippines - US Dollar" )
    , ( PL_PLN, "Poland - Polish Zloty" )
    , ( PT_EUR, "Portugal - Euro" )
    , ( XT_USD, "Portugal US Military Base - US Dollar" )
    , ( PR_USD, "Puerto Rico - US Dollar" )
    , ( QA_QAR, "Qatar - Qatari Rial" )
    , ( QY_USD, "Qatar US Military Base - US Dollar" )
    , ( RE_EUR, "Reunion Island - Euro" )
    , ( RO_EUR, "Romania - Euro" )
    , ( RO_RON, "Romania - Romanian New Leu" )
    , ( XW_USD, "Rota, CNMI - US Dollar" )
    , ( RU_RUB, "Russia - Russian Rouble" )
    , ( RU_USD, "Russia - US Dollar" )
    , ( RW_RWF, "Rwanda - Rwanda Franc" )
    , ( RW_USD, "Rwanda - US Dollar" )
    , ( BL_EUR, "Saint Barthelemy - Euro" )
    , ( KN_XCD, "Saint Kitts And Nevis - East Caribbean Dollar" )
    , ( KN_USD, "Saint Kitts And Nevis - US Dollar" )
    , ( LC_XCD, "Saint Lucia - East Caribbean Dollar" )
    , ( VC_XCD, "Saint Vincent And The Grenadines - East Caribbean Dollar" )
    , ( XU_USD, "Saipan, CNMI - US Dollar" )
    , ( WS_WST, "Samoa - Samoan Tala" )
    , ( ST_STN, "Sao Tome And Principe - Sao Tome ニュードブラ" )
    , ( SA_SAR, "Saudi Arabia - Saudi Riyal" )
    , ( XS_GBP, "Scotland - United Kingdom Pound" )
    , ( SN_XOF, "Senegal - CFA Franc BCEAO" )
    , ( YU_EUR, "Serbia - Euro" )
    , ( YU_RSD, "Serbia - Serbian Dinar" )
    , ( SC_SCR, "Seychelles - Seychelles Rupee" )
    , ( SL_SLL, "Sierra Leone - Sierra Leone Leone" )
    , ( SG_SGD, "Singapore - Singapore Dollar" )
    , ( SK_EUR, "Slovakia - Euro" )
    , ( SI_EUR, "Slovenia - Euro" )
    , ( SB_SBD, "Solomon Islands - Solomon Islands Dollar" )
    , ( XA_USD, "Somaliland - US Dollar" )
    , ( ZA_USD, "South Africa - US Dollar" )
    , ( SS_SSP, "South Sudan - South Sudanese Pound" )
    , ( SS_USD, "South Sudan - US Dollar" )
    , ( ES_EUR, "Spain - Euro" )
    , ( AB_USD, "Spain US Military Base - US Dollar" )
    , ( LK_LKR, "Sri Lanka - Sri Lanka Rupee" )
    , ( S1_ANG, "St. Maarten - Netherlands Antilles Guilder" )
    , ( S1_USD, "St. Maarten - US Dollar" )
    , ( MF_EUR, "St. Martin - Euro" )
    , ( MF_USD, "St. Martin - US Dollar" )
    , ( XD_USD, "St. Thomas - US Dollar" )
    , ( SD_SDG, "Sudan - Sudan Pound" )
    , ( SR_EUR, "Suriname - Euro" )
    , ( SR_USD, "Suriname - US Dollar" )
    , ( SZ_USD, "Swaziland - US Dollar" )
    , ( SE_SEK, "Sweden - Swedish Krona" )
    , ( CH_CHF, "Switzerland - Swiss Franc" )
    , ( SY_SYP, "Syria - Syrian Pound" )
    , ( TW_USD, "Taiwan - US Dollar" )
    , ( TJ_USD, "Tajikistan - US Dollar" )
    , ( TZ_TZS, "Tanzania - Tanzanian Shilling" )
    , ( TH_THB, "Thailand - Thai Baht" )
    , ( XV_USD, "Tinian, CNMI - US Dollar" )
    , ( TG_XOF, "Togo - CFA Franc BCEAO" )
    , ( TO_TOP, "Tonga - Tongan Pa'anga" )
    , ( TT_TTD, "Trinidad and Tobago - Trinidad/Tobago Dollar" )
    , ( TN_TND, "Tunisia - Tunisian Dinar" )
    , ( TR_EUR, "Turkey - Euro" )
    , ( TR_TRY, "Turkey - Turkish Lira" )
    , ( TR_USD, "Turkey - US Dollar" )
    , ( XN_USD, "Turkey US Military Base - US Dollar" )
    , ( TM_USD, "Turkmenistan - US Dollar" )
    , ( TC_USD, "Turks and Caicos Islands - US Dollar" )
    , ( TV_AUD, "Tuvalu - Australian Dollar" )
    , ( XE_USD, "UAE US Military Base - US Dollar" )
    , ( UG_UGX, "Uganda - Uganda Shilling" )
    , ( UA_UAH, "Ukraine - Ukraine Hryvnia" )
    , ( UA_USD, "Ukraine - US Dollar" )
    , ( AE_AED, "United Arab Emirates - Utd. Arab Emir. Dirham" )
    , ( GB_GBP, "United Kingdom - United Kingdom Pound" )
    , ( QW_USD, "United Kingdom US Military Base - US Dollar" )
    , ( US_USD, "United States - US Dollar" )
    , ( UY_UYU, "Uruguay - Peso Uruguayo" )
    , ( UY_USD, "Uruguay - US Dollar" )
    , ( UZ_USD, "Uzbekistan - US Dollar" )
    , ( VU_VUV, "Vanuatu - Vanuatu Vatu" )
    , ( VE_VIB, "Venezuela - VIB - ボリーバルフエルテ" )
    , ( VN_USD, "Vietnam - US Dollar" )
    , ( VN_VND, "Vietnam - Vietnamese Dong" )
    , ( VI_USD, "Virgin Islands (US) - US Dollar" )
    , ( XR_GBP, "Wales - United Kingdom Pound" )
    , ( YE_USD, "Yemen - US Dollar" )
    , ( ZM_ZMW, "Zambia - New Kwacha" )
    , ( ZW_USD, "Zimbabwe - US Dollar" )
    ]



--


type State
    = Empty
    | Open String
    | Closed ( Code, String )


initialState : Code -> State
initialState code =
    case List.filter (\( c, l ) -> c == code) list |> List.head of
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

        Open v ->
            case msg of
                HandleInput s ->
                    Open s

                HandleSelect picked ->
                    Closed picked

                _ ->
                    state

        Closed ( code, label ) ->
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
                    List.filter (\( _, label ) -> String.contains sanitized (String.toLower label)) list
           )


inputClass =
    class "border px-2 py-1 w-full"



-- selector :
--     State
--     -> Html Msg
-- selector state =
--     label [ class "" ]
--         [ text "Currency（通貨）"
--         , case state of
--             Empty ->
--                 input [ value "", onFocus HandleEnter, inputClass ] []
--             Closed ( code, label ) ->
--                 input [ value label, onInput HandleInput, inputClass ] []
--             Open v ->
--                 div [ class "relative" ]
--                     [ input [ value v, onInput HandleInput, inputClass ] []
--                     , div [ class "absolute left-0 mt-2 w-full rounded-md shadow-lg" ]
--                         [ div [ class "rounded-md bg-white shadow-xs overflw-y-scroll" ] <| List.map optionItem (filtered v)
--                         ]
--                     ]
--         ]


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

                Closed ( code, label ) ->
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
