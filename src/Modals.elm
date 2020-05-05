module Modals exposing (SimpleWithDismissConfig, simpleWithDismiss)

import Html exposing (Html, button, div, h3, p, span, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Icons


type alias SimpleWithDismissConfig msg =
    { title : String
    , message : String
    , okText : String
    , cancelText : String
    , okCmd : msg
    , cancelCmd : msg
    }


wrapper : Html msg -> Html msg
wrapper content =
    div [ class "fixed bottom-0 inset-x-0 px-4 pb-6 sm:inset-0 sm:p-0 flex items-center justify-center" ]
        [ div [ class "fixed inset-0 transition-opcaity" ]
            [ div [ class "absolute inset-0 bg-gray-500 opacity-75" ] []
            ]
        , content
        ]


simpleWithDismiss : SimpleWithDismissConfig msg -> Html msg
simpleWithDismiss config =
    wrapper <|
        div [ class "relative bg-white rounded-lg px-4 pt-5 pb-4 overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full sm:p-6" ]
            [ div [ class "hidden sm:block absolute top-0 right-0 pt-4 pr-4" ]
                [ button
                    [ class "text-gray-400 hover:text-gray-500 focus:outline-none focus:text-gray-500 transition ease-in-out duration-150"
                    , type_ "button"
                    , onClick config.cancelCmd
                    ]
                    [ Icons.x "h-6 w-6"
                    ]
                ]
            , div [ class "sm:flex sm:items-start" ]
                [ div [ class "mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10" ]
                    [ Icons.exclamation "h-6 w-6 text-red-600"
                    ]
                , div [ class "mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left" ]
                    [ h3 [ class "text-lg leading-6 font-medium text-gray-900" ]
                        [ text config.title ]
                    , div [ class "mt-2" ]
                        [ p [ class "text-sm leading-5 text-gray-500" ]
                            [ text config.message ]
                        ]
                    ]
                ]
            , div [ class "mt-5 sm:mt-4 sm:flex sm:flex-row-reverse" ]
                [ span [ class "flex w-full rounded-md shadow-sm sm:ml-3 sm:w-auto" ]
                    [ button
                        [ class "inline-flex justify-center w-full rounded-md border border-transparent px-4 py-2 bg-red-600 text-base leading-6 font-medium text-white shadow-sm hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                        , type_ "button"
                        , onClick config.okCmd
                        ]
                        [ text config.okText ]
                    ]
                , span [ class "mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto" ]
                    [ button
                        [ class "inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                        , type_ "button"
                        , onClick config.cancelCmd
                        ]
                        [ text config.cancelText ]
                    ]
                ]
            ]
