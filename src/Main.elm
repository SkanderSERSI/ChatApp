port module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, p, form, img, section, label, input, button)
import Html.Attributes exposing (src, class, id, for, value, style, placeholder, width, size, required)
import Html.Events exposing (onSubmit, onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import Http
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button

port receivedMessage : (Decode.Value -> msg) -> Sub msg
port sendUsername : String -> Cmd msg

type alias Model = 
  { users : List User
  , messages : List ReceivedMessage
  , message : String
  , username : String
  , connected : Bool
  }

{-| Dans notre modele on stocke des ReceivedMessage et non directement des 
    Messages car les utilisateurs doivent aussi voir le message de
    notification "x vient de se connecter"
-}

type alias Notification =
  { title : String
  }

type alias User = String

type alias Message =
  { direct : Bool  -- ce champs va etre utilisé pour ajouter du style
  , message : String
  , username : String
  }

type ReceivedMessage
  = RMessage Message
  | RNotification Notification

type Msg
  = ReceivedMessage Decode.Value
  | Connect User
  | ConnectPrivate
  | UserInput String
  | MessageInput String
  | SendMessage Message
  | MessageVide
  -- | SendDirectMessage Message User
  | SendSuccess (Result Http.Error ())
  | GotUsers (Result Http.Error (List String))

sendm : Message -> Cmd Msg
sendm message =
    Http.post
        { url = "https://cfa-chat-app.herokuapp.com/message"
        , body = Http.jsonBody (encodeMessage message)
        , expect = Http.expectWhatever SendSuccess
        }

-- senddm : Message -> User -> Cmd Msg
-- senddm message user =
--     Http.post
--         { url = "https://cfa-chat-app.herokuapp.com/direct-message"
--         , body = Http.jsonBody (encodeDMessage message user)
--         , expect = Http.expectWhatever SendSuccess
--         }

getUsers : Cmd Msg
getUsers =
    Http.post
        { url = "https://cfa-chat-app.herokuapp.com/usernames"
        , body = Http.emptyBody
        , expect = Http.expectJson GotUsers (Decode.list Decode.string)
        }

encodeMessage : Message -> Encode.Value
encodeMessage mess =
    Encode.object
        [ ("title", Encode.string "New message")
        , ("message", Encode.string mess.message)
        , ("username", Encode.string mess.username)
        ]

-- encodeDMessage : Message -> User -> Encode.Value
-- encodeDMessage mess user =
--     Encode.object
--         [ ("title", Encode.string "New direct message")
--         , ("message", Encode.string mess.message)
--         , ("username", Encode.string mess.username)
--         , ("to", Encode.string user)
--         ]

init : () -> (Model, Cmd Msg)
init () =
  ({users = [], messages = [], message = "", username = "" , connected = False }, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceivedMessage value ->
      case (Decode.decodeValue receivedDecoder value) of
        Ok union ->
          case union of
            RMessage mess ->
              if not (String.isEmpty mess.message) then ({model | messages = model.messages ++ [RMessage (Message mess.direct mess.message mess.username) ] }, Cmd.none) else (model, Cmd.none)
            RNotification notif -> 
              let name = List.head (String.split " " notif.title) in
                case name of
                  Nothing -> (model, Cmd.none)
                  Just n -> ({model | messages = model.messages ++ [ RNotification (Notification (n ++ " vient de se connecter.")) ] }, Cmd.none)--getUsers)
        Err _ ->
          (model, Cmd.none)
    Connect user -> 
      ({model | username = user, connected = True, users = model.users ++ [ String.trim user ]} , sendUsername user)
    ConnectPrivate ->  
      let inconnu = "Inconnu" in ({model | connected = True, username = inconnu, users = model.users ++ [ inconnu ]}, sendUsername inconnu)
    UserInput inp ->
      ({model | username = inp } , Cmd.none)
    MessageInput inp ->
      ({model | message = inp } , Cmd.none)
    SendMessage mess -> 
      ({model | message = ""}, sendm mess)
    MessageVide ->
      (model, Cmd.none)
    -- SendDirectMessage mess user ->
    --   ({model | message = ""}, senddm mess user)
    GotUsers res ->
      case res of
        Ok newUsers ->
          ( {model | users = newUsers }, Cmd.none)
        Err _ ->
          (model, Cmd.none)
    SendSuccess _ -> (model, Cmd.none)



spacer : Html msg
spacer = div [ style "padding" "12px" ] []

viewMessage : ReceivedMessage -> Html Msg
viewMessage mess =

    div [ class "box"]
        [ div [ style "display" "flex" ]
          [
            case mess of
              RMessage m -> div [] [ text ("[" ++ m.username ++ "]" ++ " : " ++ m.message ++ if m.direct then "X" else "" ) ]
              RNotification n -> div [] [ text n.title ]
          ]
        ]

viewUser : User -> Html Msg
viewUser user =
    div []
        [ div [ style "display" "flex" ]
            [ div [] [ text user ]
            , spacer
            ]
        ]

view : Model -> Html Msg
view model =
  if model.connected then
    let messages = List.map viewMessage model.messages
        users = List.map viewUser model.users
    in
      div [ class "grid" ]
        [ div [ class "header container"]  
          [
            h1 [ class "title is-1" ] [ text "Chat page" ]
          ] 
        , div [ class "main"]  
          [
            h1 [ class "title is-3"] [ text "Listes des messages"]
            , div [class "container"] messages
          ]
        , div [ class "aside"]  
          [
            h1 [ class "title is-3"] [ text "Listes des utilisateurs connectés"]
            , div [] users
          ]
        , div [ class "footer"]  
          [
            div [ class "control" ]
              [ form [ onSubmit (if model.message /= "" then (SendMessage (Message False model.message model.username)) else (MessageVide) ) ]
                [ input [ class "input", placeholder "Text input", value model.message, onInput MessageInput ] [] ]
              ]
          ]
        ]
  else
    section [ id "cover", class "min-vh-100" ]
      [ div [ id "cover-caption" ]
        [ div [ class "container" ]
          [ div [ class "row text-white" ]
            [ div [ class "col-xl-5 col-lg-6 col-md-8 col-sm-10 mx-auto text-center form p-4 justify-content" ]
              [ div [ class "form-group" ]
                [ h1 [ class "display-4 py-2 text-truncate" ] [ text "Blablachat" ]
                , div[ class "px-2" ] [ Input.text[ Input.id "username", Input.placeholder "Entrez votre pseudo", Input.value model.username, Input.onInput UserInput ] ]
                , div [] []
                , Button.button [ Button.primary, Button.attrs [ onClick(if model.username /= "" then (Connect model.username) else ConnectPrivate) ] ] [ text "Connect" ]  
                ]
              ]
            ] 
          ]
        ]
      ]
    
--si quelqu'un ne renseigne pas de pseudo alors on le laisse se connecter
--quand meme car un utilisateur en moins = moins de $$$ avec tout les ad quand mettra sur la page de chat

--message Decoder
messageDecoder : Decode.Decoder Message
messageDecoder = Decode.map3 Message
    (Decode.field "direct" Decode.bool)
    (Decode.field "message" Decode.string)
    (Decode.field "username" Decode.string)

--notification Decoder
notificationDecoder : Decode.Decoder Notification
notificationDecoder = Decode.map Notification
    (Decode.field "title" Decode.string)

-- received message Decoder
receivedDecoder : Decode.Decoder ReceivedMessage
receivedDecoder = Decode.oneOf [ (Decode.map RMessage messageDecoder), (Decode.map RNotification notificationDecoder) ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ receivedMessage ReceivedMessage ]

main : Program () Model Msg
main =
  Browser.element
    { view = view
    , init = init
    , update = update
    , subscriptions = subscriptions
    }
