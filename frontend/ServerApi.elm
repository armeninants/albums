module ServerApi where


import Json.Decode as JsonD exposing ((:=))
import Json.Encode as JsonE
import Effects exposing (Effects)
import Http
import Task


type alias ArtistRequest a =
  { a | name : String }

type alias Artist =
  { id : Int
  , name : String
  }

baseUrl : String
baseUrl = "http://localhost:8081"


getArtist : Int -> (Maybe Artist -> a) -> Effects.Effects a
getArtist id action =
  Http.get artistDecoder (baseUrl ++ "/artists/" ++ toString id)
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task


getArtists : (Maybe (List Artist) -> a) -> Effects a
getArtists action =
  Http.get artistsDecoder (baseUrl ++ "/artists")
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task

createArtist : ArtistRequest a -> (Maybe Artist -> b) -> Effects.Effects b
createArtist artist action =
  Http.send Http.defaultSettings
        { verb = "POST"
        , url = baseUrl ++ "/artists"
        , body = Http.string (encodeArtist artist)
        , headers = [("Content-Type", "application/json")]
        }
    |> Http.fromJson artistDecoder
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task


updateArtist : Artist -> (Maybe Artist -> a) -> Effects.Effects a
updateArtist artist action =
  Http.send Http.defaultSettings
        { verb = "PUT"
        , url = baseUrl ++ "/artists/" ++ toString artist.id
        , body = Http.string (encodeArtist artist)
        , headers = [("Content-Type", "application/json")]
        }
    |> Http.fromJson artistDecoder
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task



deleteArtist : Int -> (Maybe Http.Response -> a) -> Effects.Effects a
deleteArtist id action =
  Http.send Http.defaultSettings
        { verb = "DELETE"
        , url = baseUrl ++ "/artists/" ++ toString id
        , body = Http.empty
        , headers = []
        }
    |> Task.toMaybe
    |> Task.map action
    |> Effects.task



artistsDecoder : JsonD.Decoder (List Artist)
artistsDecoder =
  JsonD.list artistDecoder


artistDecoder : JsonD.Decoder Artist
artistDecoder =
  JsonD.object2 Artist
    ("artistId" := JsonD.int)
    ("artistName" := JsonD.string)



encodeArtist : ArtistRequest a -> String
encodeArtist a =
  JsonE.encode 0 <|
    JsonE.object
      [
        ("artistName", JsonE.string a.name)
      ]

