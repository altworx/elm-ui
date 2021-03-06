import Date.Config.Configs as DateConfigs
import Signal exposing (forwardTo)
import Signal.Time
import Maybe.Extra
import Date.Format
import List.Extra
import Ext.Color
import Ext.Date
import StartApp
import Keyboard
import Effects
import Mouse
import Color
import Task
import Date
import Time
import Set

import Html.Attributes exposing (style, classList, class, colspan, href)
import Html.Events exposing (onClick)
import Html exposing (div, text, node, table, tr, td)
import Html.Lazy

import Debug exposing (log)

import Ui.NotificationCenter
import Ui.DropdownMenu
import Ui.InplaceInput
import Ui.SearchInput
import Ui.NumberRange
import Ui.ButtonGroup
import Ui.ColorPicker
import Ui.DatePicker
import Ui.ColorPanel
import Ui.IconButton
import Ui.NumberPad
import Ui.Container
import Ui.Calendar
import Ui.Checkbox
import Ui.Textarea
import Ui.Chooser
import Ui.Ratings
import Ui.Button
import Ui.Tagger
import Ui.Slider
import Ui.Loader
import Ui.Pager
import Ui.Modal
import Ui.Image
import Ui.Input
import Ui.Time
import Ui.Tabs
import Ui.App
import Ui

import Kitchensink.Showcase as Showcase

type Action
  = InplaceInput (Showcase.Action Ui.InplaceInput.Action)
  | NumberRange (Showcase.Action Ui.NumberRange.Action)
  | ColorPicker (Showcase.Action Ui.ColorPicker.Action)
  | SearchInput (Showcase.Action Ui.SearchInput.Action)
  | DatePicker (Showcase.Action Ui.DatePicker.Action)
  | ColorPanel (Showcase.Action Ui.ColorPanel.Action)
  | DropdownMenu Ui.DropdownMenu.Action
  | NumberPad (Showcase.Action Ui.NumberPad.Action)
  | Notis Ui.NotificationCenter.Action
  | Checkbox2 (Showcase.Action Ui.Checkbox.Action)
  | Checkbox3 (Showcase.Action Ui.Checkbox.Action)
  | TextArea (Showcase.Action Ui.Textarea.Action)
  | Calendar (Showcase.Action Ui.Calendar.Action)
  | Checkbox (Showcase.Action Ui.Checkbox.Action)
  | Chooser (Showcase.Action Ui.Chooser.Action)
  | Ratings (Showcase.Action Ui.Ratings.Action)
  | Slider (Showcase.Action Ui.Slider.Action)
  | Tagger (Showcase.Action (Ui.Tagger.Action TaggerModel String))
  | Input (Showcase.Action Ui.Input.Action)
  | Tabs (Showcase.Action Ui.Tabs.Action)
  | Image Ui.Image.Action
  | Modal Ui.Modal.Action
  | Pager Ui.Pager.Action
  | App Ui.App.Action
  | MousePosition (Int, Int)
  | MouseIsDown Bool
  | ShowNotification
  | AppAction String
  | EscIsDown Bool
  | Open String
  | CloseMenu
  | CloseModal
  | OpenModal
  | NoOp
  | Alert
  | Tick Time.Time
  | PreviousPage
  | NextPage
  | ChooserChanged (Set.Set String)
  | NumberRangeChanged Float
  | ColorPanelChanged Ext.Color.Hsv
  | ColorPickerChanged Ext.Color.Hsv
  | DatePickerChanged Time.Time
  | InplaceInputChanged String
  | TaggerAddFailed String
  | CalendarChanged Time.Time
  | SearchInputChanged String
  | BreadcrumbClicked String
  | Checkbox2Changed Bool
  | Checkbox3Changed Bool
  | CheckboxChanged Bool
  | RatingsChanged Float
  | ButtonClicked String
  | Scrolled Bool
  | Loaded Bool

type alias TaggerModel =
  { label : String, id : Int }

type alias Model =
  { app : Ui.App.Model
  , mailbox : Signal.Mailbox Action
  , settledMailbox : Signal.Mailbox Action
  , notifications : Ui.NotificationCenter.Model
  , dropdownMenu : { address : Signal.Address Ui.DropdownMenu.Action
                   , content : Html.Html
                   , items : List Html.Html
                   }
  , pagerControls : Html.Html
  , pagerContents : List Html.Html
  , pagerAddress : Signal.Address Ui.Pager.Action
  , modalButton : Html.Html
  , modalView : Ui.Modal.ViewModel
  , infos : List Html.Html
  , disabledIconButton : List Html.Html
  , disabledButton : List Html.Html
  , iconButtons : List Html.Html
  , buttons : List Html.Html
  , notificationButton : Html.Html
  , buttonGroup :
    { enabled: Ui.ButtonGroup.Model Action
    , disabled: Ui.ButtonGroup.Model Action
    }
  , searchInput : Showcase.Model Ui.SearchInput.Model Ui.SearchInput.Action
  , numberPadViewFn : Signal.Address Ui.NumberPad.Action -> Ui.NumberPad.Model -> Html.Html
  , inplaceInput : Showcase.Model Ui.InplaceInput.Model Ui.InplaceInput.Action
  , tagger : Showcase.Model (Ui.Tagger.Model TaggerModel Int String) (Ui.Tagger.Action TaggerModel String)
  , colorPicker : Showcase.Model Ui.ColorPicker.Model Ui.ColorPicker.Action
  , numberRange : Showcase.Model Ui.NumberRange.Model Ui.NumberRange.Action
  , colorPanel : Showcase.Model Ui.ColorPanel.Model Ui.ColorPanel.Action
  , datePicker : Showcase.Model Ui.DatePicker.Model Ui.DatePicker.Action
  , numberPad : Showcase.Model Ui.NumberPad.Model Ui.NumberPad.Action
  , checkbox3 : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Action
  , checkbox2 : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Action
  , checkbox : Showcase.Model Ui.Checkbox.Model Ui.Checkbox.Action
  , textarea : Showcase.Model Ui.Textarea.Model Ui.Textarea.Action
  , calendar : Showcase.Model Ui.Calendar.Model Ui.Calendar.Action
  , ratings : Showcase.Model Ui.Ratings.Model Ui.Ratings.Action
  , chooser : Showcase.Model Ui.Chooser.Model Ui.Chooser.Action
  , slider : Showcase.Model Ui.Slider.Model Ui.Slider.Action
  , input : Showcase.Model Ui.Input.Model Ui.Input.Action
  , tabs : Showcase.Model Ui.Tabs.Model Ui.Tabs.Action
  , tabsContents : List (String, Html.Html)
  , menu : Ui.DropdownMenu.Model
  , loader : Ui.Loader.Model
  , modal : Ui.Modal.Model
  , image : Ui.Image.Model
  , pager : Ui.Pager.Model
  , time2 : Ui.Time.Model
  , time : Ui.Time.Model
  , clicked : Bool
  }

dateConfig =
  (DateConfigs.getConfig "en")

handleMoveIdentity x y model = (model, Effects.none)
handleClickIndetity pressed model = model

removeLabel : TaggerModel -> Task.Task String TaggerModel
removeLabel item =
  if item.id == 0 then
    Task.fail "Can't remove this item..."
  else
    Task.succeed item

createLabel : String -> List TaggerModel -> Task.Task String TaggerModel
createLabel label items =
  let
    id =
      List.map .id items
      |> List.maximum
      |> Maybe.withDefault -1
  in
    if label == "xxx" then
      Task.fail "xxx is not a valid label..."
    else
      Task.succeed { label = label, id = id + 1 }

taggerData : List TaggerModel
taggerData =
  [ { label = "Pear", id = 2 }
  , { label = "Apple", id = 1 }
  , { label = "Orange", id = 0 }
  ]

init : Model
init =
  let
    input = Ui.Input.init "" "Type here..."
    pager = Ui.Pager.init 0
    loader = Ui.Loader.init 0

    address = mailbox.address

    numberPadViewModel =
      { bottomLeft = text ""
      , bottomRight = text ""
      }

    settledMailbox = Signal.mailbox NoOp
    mailbox = Signal.mailbox NoOp

    -- datePicker =
    --  { datePickerOptions | format = "%Y %B %e." }

    inplaceInput localAddress =
      Ui.InplaceInput.initWithAddress
        (forwardTo address InplaceInputChanged)
        "Test Value"

    buttonGroup =
      Ui.ButtonGroup.init [("A", (ButtonClicked "A")),
                           ("B", (ButtonClicked "B")),
                           ("C", (ButtonClicked "C")),
                           ("D", (ButtonClicked "D"))]

  in
    { calendar =
        Showcase.init
          (\_-> Ui.Calendar.initWithAddress
                (forwardTo address CalendarChanged)
                (Ext.Date.createDate 2015 5 1))
          (forwardTo address Calendar)
          Ui.Calendar.update
          handleMoveIdentity
          handleClickIndetity
    , tabs =
         Showcase.init
          (\_ -> Ui.Tabs.init 0)
          (forwardTo address Tabs)
          Ui.Tabs.update
          handleMoveIdentity
          handleClickIndetity
    , tabsContents = [("First", text "First Tab")
                     ,("Second", text "Second Tab")
                     ,("Third", text "Third Tab")
                     ]
    , tagger =
        Showcase.init
          (\_ ->
            Ui.Tagger.initWithAddress
              (forwardTo address TaggerAddFailed)
              taggerData
              "Add a tag..."
              .label
              .id
              createLabel
              removeLabel
          )
          (forwardTo address Tagger)
          Ui.Tagger.update
          handleMoveIdentity
          handleClickIndetity
    , searchInput =
        Showcase.init
          (\_ -> Ui.SearchInput.initWithAddress (forwardTo address SearchInputChanged) 1000)
          (forwardTo address SearchInput)
          Ui.SearchInput.update
          handleMoveIdentity
          handleClickIndetity
    , numberPadViewFn = (Ui.NumberPad.view numberPadViewModel)
    , notificationButton = Ui.IconButton.primary
                            "Show Notification"
                            "alert-circled"
                            "right"
                            address
                            ShowNotification
    , pagerContents =
        [ text "Page 1"
        , text "Page 2"
        , text "Page 3"
        ]
    , pagerAddress = (forwardTo address Pager)
    , pagerControls =
        Ui.Container.row []
          [ Ui.IconButton.primary "Previous Page" "chevron-left" "left" address PreviousPage
          , Ui.spacer
          , Ui.IconButton.primary "Next Page" "chevron-right" "right" address NextPage
          ]
    , dropdownMenu =
      { address = forwardTo address DropdownMenu
      , content = Ui.IconButton.secondary
                    "Open" "chevron-down" "right" address NoOp
      , items =
        [ Ui.DropdownMenu.item
          [ onClick address CloseMenu ]
          [ Ui.icon "android-download" True []
          , node "span" [] [text "Download"]
          ]
        , Ui.DropdownMenu.item
          [ onClick address CloseMenu ]
          [ Ui.icon "trash-b" True []
          , node "span" [] [text "Delete"]
          ]
        ]
    }
    , infos =
      [ Ui.title [] [text "Elm-UI Kitchen Sink"]
      , Ui.textBlock "An opinionated UI library for the web in Elm, following
                      the Elm Architecture."
      , node "p" []
        [ Ui.IconButton.primaryBig
            "Get Started at Github" "social-github" "right"
            address (Open "https://github.com/gdotdesign/elm-ui") ]
      , Ui.subTitle [] [text "Components"]
      , Ui.textBlock "The business logic for following components are
                      implemented fully in Elm, with minimal Native
                      bindings, following the Elm Architecture. Most
                      components implement disabled and readonly states."
      ]
    , modalButton =
      Ui.IconButton.primary
       "Open Modal" "android-open" "right" address OpenModal
    , modalView = { title = "Test Modal"
                  , content =
                    [ node "p" [] [text "This is a modal window."]
                    , node "p" [] [text "Lorem ipsum dolor sit amet, consectetur
                                         adipiscing elit. Pellentesque ornare odio sed
                                         lorem malesuada, id efficitur elit consequat.
                                         Aenean suscipit, est a varius aliquam,
                                         turpis diam sollicitudin tortor, in venenatis
                                         felis nisl ac ex. Quisque finibus nisl nec urna
                                         laoreet aliquet. Maecenas et volutpat arcu, a
                                         dapibus tellus. Praesent nec enim velit. Class
                                         aptent taciti sociosqu ad litora torquent per
                                         conubia nostra, per inceptos himenaeos. Nullam
                                         volutpat turpis vel lorem fringilla, pulvinar
                                         viverra dolor varius."]
                    ]
                  , footer =
                    [ Ui.Container.rowEnd []
                      [ Ui.Button.primary "Close" address CloseModal ]
                    ]
                  }
    , buttons = [ Ui.Button.primaryBig "Primary" address Alert
                , Ui.Button.secondary "Secondary" address NoOp
                , Ui.Button.success "Success" address NoOp
                , Ui.Button.warning "Warning" address NoOp
                , Ui.Button.dangerSmall "Danger" address NoOp
                ]
    , disabledIconButton = [ Ui.IconButton.view address NoOp
                              { side = "left"
                              , text = "Disabled"
                              , kind = "success"
                              , glyph = "paper-airplane"
                              , size = "medium"
                              , disabled = True }
                           ]
    , disabledButton = [ Ui.Button.view address NoOp { text = "Disabled"
                                                        , kind = "danger"
                                                        , size = "medium"
                                                        , disabled = True }
                      ]
    , iconButtons = [ Ui.IconButton.primaryBig
                        "Load" "android-download" "right" address NoOp
                    , Ui.IconButton.primary
                        "" "archive" "right" address NoOp
                    , Ui.IconButton.secondary
                        "Send" "arrow-left-c" "left" address NoOp
                    , Ui.IconButton.success
                        "Success" "checkmark" "right" address NoOp
                    , Ui.IconButton.warning
                        "Warning" "alert" "right" address NoOp
                    , Ui.IconButton.dangerSmall
                        "Danger" "close" "right" address NoOp
                    ]
    , datePicker =
        Showcase.init
          (\localAddress ->
            Ui.DatePicker.initWithAddress
              (forwardTo address DatePickerChanged)
              localAddress
              (Ext.Date.now ()))
          (forwardTo address DatePicker)
          Ui.DatePicker.update
          handleMoveIdentity
          handleClickIndetity
    , pager = { pager | width = "100%", height = "200px" }
    , notifications = Ui.NotificationCenter.init 4000 320
    , input =
        Showcase.init
          (\_ -> input)
          (forwardTo address Input)
          Ui.Input.update
          handleMoveIdentity
          handleClickIndetity
    , inplaceInput =
        Showcase.init
          inplaceInput
          (forwardTo address InplaceInput)
          Ui.InplaceInput.update
          handleMoveIdentity
          handleClickIndetity
    , colorPicker =
        Showcase.init
          (\_ ->
            Ui.ColorPicker.initWithAddress
            (forwardTo settledMailbox.address ColorPickerChanged)
            Color.yellow)
          (forwardTo address ColorPicker)
          Ui.ColorPicker.update
          Ui.ColorPicker.handleMove
          Ui.ColorPicker.handleClick
    , colorPanel =
        Showcase.init
          (\_->
            Ui.ColorPanel.initWithAddress
            (forwardTo settledMailbox.address ColorPanelChanged)
            Color.blue)
          (forwardTo address ColorPanel)
          Ui.ColorPanel.update
          Ui.ColorPanel.handleMove
          Ui.ColorPanel.handleClick
    , numberRange =
        Showcase.init
          (\_->
            Ui.NumberRange.initWithAddress
            (forwardTo settledMailbox.address NumberRangeChanged)
            0)
          (forwardTo address NumberRange)
          Ui.NumberRange.update
          Ui.NumberRange.handleMove
          Ui.NumberRange.handleClick
    , buttonGroup = { enabled = buttonGroup
                    , disabled = { buttonGroup | disabled = True }
                    }
    , checkbox3 =
        Showcase.init
          (\_-> Ui.Checkbox.initWithAddress (forwardTo address Checkbox3Changed) False)
          (forwardTo address Checkbox3)
          Ui.Checkbox.update
          handleMoveIdentity
          handleClickIndetity
    , checkbox2 =
        Showcase.init
          (\_-> Ui.Checkbox.initWithAddress (forwardTo address Checkbox2Changed) False)
          (forwardTo address Checkbox2)
          Ui.Checkbox.update
          handleMoveIdentity
          handleClickIndetity
    , checkbox =
        Showcase.init
          (\_-> Ui.Checkbox.initWithAddress (forwardTo address CheckboxChanged) False)
          (forwardTo address Checkbox)
          Ui.Checkbox.update
          handleMoveIdentity
          handleClickIndetity
    , textarea =
        Showcase.init
          (\_ -> Ui.Textarea.init "Test")
          (forwardTo address TextArea)
          Ui.Textarea.update
          handleMoveIdentity
          handleClickIndetity
    , numberPad =
        Showcase.init
          (\_ -> Ui.NumberPad.init 0)
          (forwardTo address NumberPad)
          Ui.NumberPad.update
          handleMoveIdentity
          handleClickIndetity
    , image = Ui.Image.init imageUrl
    , ratings =
        Showcase.init
          (\_ -> Ui.Ratings.initWithAddress (forwardTo address RatingsChanged) 5 0.4)
          (forwardTo address Ratings)
          Ui.Ratings.update
          handleMoveIdentity
          handleClickIndetity
    , slider =
        Showcase.init
          (\_ -> Ui.Slider.init 50)
          (forwardTo address Slider)
          Ui.Slider.update
          Ui.Slider.handleMove
          Ui.Slider.handleClick
    , menu = Ui.DropdownMenu.init
    , modal = Ui.Modal.init
    , loader = { loader | shown = True }
    , time = Ui.Time.init (Ext.Date.createDate 2015 11 1)
    , time2 = Ui.Time.init (Ext.Date.now ())
    , settledMailbox = settledMailbox
    , mailbox = mailbox
    , clicked = False
    , chooser =
        Showcase.init
          (\_ -> Ui.Chooser.initWithAddress
                  (forwardTo address ChooserChanged)
                  data
                  "Select a country..." "")
          (forwardTo address Chooser)
          Ui.Chooser.update
          handleMoveIdentity
          handleClickIndetity
    , app = Ui.App.initWithAddress
        (forwardTo address Loaded)
        (forwardTo address Scrolled)
        "Elm-UI Kitchen Sink"
    }

data : List Ui.Chooser.Item
data =
  [ { label = "Hungary",                      value = "0" }
  , { label = "Germany",                      value = "1" }
  , { label = "French" ,                      value = "2" }
  , { label = "Italy"  ,                      value = "3" }
  , { label = "Russia" ,                      value = "4" }
  , { label = "Some very long named country", value = "5" }
  ]

imageUrl : String
imageUrl =
  "http://rs1371.pbsrc.com/albums/ag299/Victor_Binhara/Despicable%20Me/DespicableMe2_zpsc67ebdc5.jpg~c200"

componentHeader : String -> Html.Html
componentHeader title =
  Html.Lazy.lazy componentHeaderRender title

componentHeaderRender : String -> Html.Html
componentHeaderRender title =
  tr [] [ td [colspan 3] [text title] ]

tableRow : Html.Html -> Html.Html -> Html.Html -> Html.Html
tableRow active readonly disabled =
  tr []
    [ td [] [ active   ]
    , td [] [ readonly ]
    , td [] [ disabled ]
    ]

view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    emptyText = text ""

    { chooser, colorPanel, datePicker, colorPicker, numberRange, slider
    , checkbox, checkbox2, checkbox3, calendar, inplaceInput, textarea
    , numberPad, ratings, pager, input, buttonGroup, buttons, iconButtons
    , disabledButton, disabledIconButton, modalView, infos, modalButton
    , dropdownMenu, pagerControls, notificationButton, numberPadViewFn
    , pagerAddress, pagerContents, searchInput, tagger, tabs, tabsContents
    } = model

    clicked =
      if model.clicked then [node "clicked" [] [emptyText]] else []

  in
    Ui.App.view (forwardTo address App) model.app
      [ Ui.NotificationCenter.view (forwardTo address Notis) model.notifications
      , Ui.Modal.view
        (forwardTo address Modal)
        modalView
        model.modal
      , node "kitchen-sink" []
        (infos ++ [ table []
          [ tr [] [ td [] [text "Active"]
                  , td [] [text "Readonly"]
                  , td [] [text "Disabled"]
                  ]

          , componentHeader "Button"
          , tr []
            [ td [colspan 2]
              [ Ui.Container.row [] (buttons ++ clicked) ]
            , td [] disabledButton
            ]

          , componentHeader "Icon Button"
          , tr []
            [ td [colspan 2]
              [ Ui.Container.row [] iconButtons
              ]
            , td [] disabledIconButton
            ]
          , componentHeader "Button Group"
          , tableRow (Ui.ButtonGroup.view address buttonGroup.enabled)
                     (emptyText)
                     (Ui.ButtonGroup.view address buttonGroup.disabled)

          , componentHeader "Ratings"
          , Showcase.view Ui.Ratings.view ratings

          , componentHeader "NotificationCenter"
          , tableRow (notificationButton)
                     (emptyText)
                     (emptyText)

          , componentHeader "Modal"
          , tableRow (modalButton)
                     (emptyText)
                     (emptyText)

          , componentHeader "Dropdown Menu"
          , tableRow ( Ui.DropdownMenu.view
                       dropdownMenu.address
                       dropdownMenu.content
                       dropdownMenu.items
                       model.menu)
                     (emptyText)
                     (emptyText)
          , componentHeader "Calendar"
          , Showcase.view Ui.Calendar.view calendar

          , componentHeader "Tabs"
          , Showcase.view (Ui.Tabs.view tabsContents) tabs

          , componentHeader "Checkbox"
          , Showcase.view Ui.Checkbox.view checkbox
          , Showcase.view Ui.Checkbox.toggleView checkbox2
          , Showcase.view Ui.Checkbox.radioView checkbox3

          , componentHeader "Chooser"
          , Showcase.view Ui.Chooser.view chooser

          , componentHeader "Color Panel"
          , Showcase.view Ui.ColorPanel.view colorPanel

          , componentHeader "Color Picker"
          , Showcase.view Ui.ColorPicker.view colorPicker

          , componentHeader "Date Picker"
          , Showcase.view Ui.DatePicker.view datePicker

          , componentHeader "Number Range"
          , Showcase.view Ui.NumberRange.view numberRange

          , componentHeader "Slider"
          , Showcase.view Ui.Slider.view slider

          , componentHeader "Tagger"
          , Showcase.view Ui.Tagger.view tagger

          , componentHeader "Time"
          , tableRow
              (Ui.Time.view model.time)
              (Ui.Time.view model.time2)
              emptyText

          , componentHeader "Loader"
          , tableRow
              (Ui.Loader.barView model.loader)
              (div [class "loader-container"]
                [ Ui.Loader.overlayView model.loader ])
              emptyText

          , componentHeader "Input"
          , Showcase.view Ui.Input.view input

          , componentHeader "Search Input"
          , Showcase.view Ui.SearchInput.view searchInput

          , componentHeader "Autogrow Textarea"
          , Showcase.view Ui.Textarea.view textarea

          , componentHeader "Inplace Input"
          , Showcase.view Ui.InplaceInput.view inplaceInput

          , componentHeader "Number Pad"
          , Showcase.view numberPadViewFn numberPad

          , componentHeader "Pager"
          , tr []
            [ td [colspan 3]
              [ Ui.Pager.view pagerAddress pagerContents pager
              ]
            ]
          , tr []
            [ td [colspan 3]
              [ pagerControls ]
            ]

          , componentHeader "Breadcrumbs"
          , tr []
            [ td [colspan 3]
              [ Ui.breadcrumbs address (node "span" [] [text "/"])
                [ ("First", Just (BreadcrumbClicked "First"))
                , ("Second", Just (BreadcrumbClicked "Second"))
                , ("Third", Nothing)
                ]
              ]
            ]
          , componentHeader "Image"
          , tr []
            [ td []
              [ Ui.Image.view (forwardTo address Image) model.image ]
            , td [] []
            , td [] []
            ]
          ]
        ])
      ]

update : Action -> Model -> Model
update action model =
  case action of
    DropdownMenu act ->
      { model | menu = Ui.DropdownMenu.update act model.menu }

    Modal act ->
      { model | modal = Ui.Modal.update act model.modal }

    Image act ->
      { model | image = Ui.Image.update act model.image }

    Pager act ->
      { model | pager = Ui.Pager.update act model.pager }

    MouseIsDown value ->
      { model
        | numberRange = Showcase.handleClick value model.numberRange
        , colorPicker = Showcase.handleClick value model.colorPicker
        , colorPanel = Showcase.handleClick value model.colorPanel
        , menu = Ui.DropdownMenu.handleClick value model.menu
        , slider = Showcase.handleClick value model.slider
        }

    Scrolled _ ->
      { model | menu = Ui.DropdownMenu.close model.menu }

    CloseMenu ->
      { model | menu = Ui.DropdownMenu.close model.menu }

    Open url ->
      Ui.open url model

    NextPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active + 1)) model.pager }

    PreviousPage ->
      { model | pager = Ui.Pager.select (clamp 0 2 (model.pager.active - 1)) model.pager }

    EscIsDown bool ->
      { model | menu = Ui.DropdownMenu.close model.menu
              , modal = Ui.Modal.close model.modal
      }

    CloseModal ->
      { model | modal = Ui.Modal.close model.modal }

    OpenModal ->
      { model | modal = Ui.Modal.open model.modal }

    Alert ->
      { model | clicked = True }

    _ ->
      model

update' : Action -> Model -> (Model, Effects.Effects Action)
update' action model =
  case action of
    Tabs act ->
      let
        (tabs, effect) = Showcase.update act model.tabs
      in
        ({ model | tabs = tabs }, Effects.map Tabs effect)
    Tagger act ->
      let
        (tagger, effect) = Showcase.update act model.tagger
      in
        ({ model | tagger = tagger }, Effects.map Tagger effect)
    SearchInput act ->
      let
        (searchInput, effect) = Showcase.update act model.searchInput
      in
        ({ model | searchInput = searchInput }, Effects.map SearchInput effect)
    Input act ->
      let
        (input, effect) = Showcase.update act model.input
      in
        ({ model | input = input }, Effects.map Input effect)
    TextArea act ->
      let
        (textarea, effect) = Showcase.update act model.textarea
      in
        ({ model | textarea = textarea }, Effects.map TextArea effect)
    NumberPad act ->
      let
        (numberPad, effect) = Showcase.update act model.numberPad
      in
        ({ model | numberPad = numberPad }, Effects.map NumberPad effect)

    InplaceInput act ->
      let
        (inplaceInput, effect) = Showcase.update act model.inplaceInput
      in
        ({ model | inplaceInput = inplaceInput }, Effects.map InplaceInput effect)

    Chooser act ->
      let
        (chooser, effect) = Showcase.update act model.chooser
      in
        ({ model | chooser = chooser }, Effects.map Chooser effect)
    Checkbox2 act ->
      let
        (checkbox2, effect) = Showcase.update act model.checkbox2
      in
        ({ model | checkbox2 = checkbox2 }, Effects.map Checkbox2 effect)
    Checkbox3 act ->
      let
        (checkbox3, effect) = Showcase.update act model.checkbox3
      in
        ({ model | checkbox3 = checkbox3 }, Effects.map Checkbox3 effect)
    Checkbox act ->
      let
        (checkbox, effect) = Showcase.update act model.checkbox
      in
        ({ model | checkbox = checkbox }, Effects.map Checkbox effect)
    ColorPicker act ->
      let
        (colorPicker, effect) = Showcase.update act model.colorPicker
      in
        ({ model | colorPicker = colorPicker }, Effects.map ColorPicker effect)
    ColorPanel act ->
      let
        (colorPanel, effect) = Showcase.update act model.colorPanel
      in
        ({ model | colorPanel = colorPanel }, Effects.map ColorPanel effect)

    DatePicker act ->
      let
        (datePicker, effect) = Showcase.update act model.datePicker
      in
        ({ model | datePicker = datePicker }, Effects.map DatePicker effect)

    Calendar act ->
      let
        (calendar, effect) = Showcase.update act model.calendar
      in
        ({ model | calendar = calendar}, Effects.map Calendar effect)
    Ratings act ->
      let
        (ratings, effect) = Showcase.update act model.ratings
      in
        ({ model | ratings = ratings }, Effects.map Ratings effect)
    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Effects.map App effect)
    Notis act ->
      let
        (notis, effect) = Ui.NotificationCenter.update act model.notifications
      in
        ({ model | notifications = notis }, Effects.map Notis effect)
    NumberRange act ->
      let
        (numberRange, effect) = Showcase.update act model.numberRange
      in
        ({ model | numberRange = numberRange}, Effects.map NumberRange effect)
    Slider act ->
      let
        (slider, effect) = Showcase.update act model.slider
      in
        ({ model | slider = slider }, Effects.map Slider effect)

    MousePosition (x,y) ->
      let
        (colorPicker, colorPickerEffect) =
          Showcase.handleMove x y model.colorPicker
        (colorPanel, colorPanelEffect) =
          Showcase.handleMove x y model.colorPanel
        (numberRange, numberRangeEffect) =
          Showcase.handleMove x y model.numberRange
        (slider, sliderEffect) =
          Showcase.handleMove x y model.slider
      in
        ({ model
          | numberRange = numberRange
          , colorPicker = colorPicker
          , colorPanel = colorPanel
          , slider = slider
          }, Effects.batch [ Effects.map ColorPanel colorPanelEffect
                           , Effects.map ColorPicker colorPickerEffect
                           , Effects.map NumberRange numberRangeEffect
                           , Effects.map Slider sliderEffect
                           ])
    ButtonClicked value ->
      notify ("Button clicked: " ++ value) model
    BreadcrumbClicked value ->
      notify ("Breadcrumb clicked:" ++ value) model
    InplaceInputChanged value ->
      notify ("Inplace input changed to: " ++ value) model
    CheckboxChanged value ->
      notify ("Checkbox changed to: " ++ (toString value)) model
    Checkbox2Changed value ->
      notify ("Toggle changed to: " ++ (toString value)) model
    Checkbox3Changed value ->
      notify ("Radio changed to: " ++ (toString value)) model
    SearchInputChanged value ->
      notify ("Search input changed to: " ++ (toString value)) model
    ColorPickerChanged value ->
      notify ("Color picker changed to: " ++ (Ext.Color.toCSSRgba value)) model
    NumberRangeChanged value ->
       notify ("Number range changed to: " ++ (toString value)) model
    ColorPanelChanged value ->
      notify ("Color panel changed to: " ++ (Ext.Color.toCSSRgba value)) model
    ShowNotification ->
      notify "Test Notification" model
    ChooserChanged set ->
      let
        selected =
          Ui.Chooser.getFirstSelected model.chooser.enabled
          |> Maybe.map (\value -> List.Extra.find (\item -> item.value == value) data)
          |> Maybe.Extra.join
          |> Maybe.map .label
          |> Maybe.withDefault ""
      in
        notify ("Chooser changed to: " ++ selected) model
    CalendarChanged time ->
      notify ("Calendar changed to: " ++ (Date.Format.format dateConfig "%Y-%m-%d" (Date.fromTime time))) model
    DatePickerChanged time ->
      notify ("Date picker changed to: " ++ (Date.Format.format dateConfig "%Y-%m-%d" (Date.fromTime time))) model
    RatingsChanged value ->
      notify ("Ratings changed to: " ++ (toString (Ui.Ratings.valueAsStars value model.ratings.enabled))) model
    TaggerAddFailed err ->
      notify err model
    _ ->
      (update action model, Effects.none)

notify : String -> Model -> (Model, Effects.Effects Action)
notify message model =
  let
    (notis, effect) = Ui.NotificationCenter.notify (text message) model.notifications
  in
    ({ model | notifications = notis }, Effects.map Notis effect)

app =
  let
    initial =
      init

    inputs =
      -- Lifecycle
      [ Signal.map EscIsDown (Keyboard.isDown 27)
      , Signal.map MousePosition Mouse.position
      , Signal.map MouseIsDown Mouse.isDown
      -- Mailbox
      , Signal.Time.settledAfter 500 initial.settledMailbox.signal
      , initial.mailbox.signal
      , Signal.map Tick (Time.every 10000)
      ]
  in
    StartApp.start { init = (initial, Effects.none)
                   , view = view
                   , update = update'
                   , inputs = inputs
                   }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
