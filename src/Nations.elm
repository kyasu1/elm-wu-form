module Nations exposing (Nation, list)


type alias Nation =
    { code : String
    , titleEn : String
    , titleJa : String
    }


list : List Nation
list =
    []
