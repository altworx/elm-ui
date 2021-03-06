module Ui.Container
  ( Model, view, row, rowEnd, rowCenter, rowStart, column, columnStart
  , columnEnd, columnCenter, render) where

{-| Flexbox container component.

# Model
@docs Model

# View
@docs view, render

# Row
@docs row, rowStart, rowEnd, rowCenter

# Column
@docs column, columnStart, columnEnd, columnCenter
-}
import Html.Attributes exposing (classList, style)
import Html exposing (node)
import Html.Lazy

{-| Representation of a container. -}
type alias Model =
  { direction : String
  , align : String
  , compact : Bool
  }

-- Options for row
rowOptions : Model
rowOptions =
  { direction = "row"
  , align = "stretch"
  , compact = False
  }

-- Options for column
columnOptions : Model
columnOptions =
  { direction = "column"
  , align = "stretch"
  , compact = False
  }

{-| Renders a container. -}
view : Model -> List Html.Attribute -> List Html.Html -> Html.Html
view model attributes children =
  Html.Lazy.lazy3 render model attributes children

{-| Renders a container as a row. -}
row : List Html.Attribute -> List Html.Html -> Html.Html
row attributes children =
  Html.Lazy.lazy3 render rowOptions attributes children

{-| Renders a container as a row with content aligned to start. -}
rowStart : List Html.Attribute -> List Html.Html -> Html.Html
rowStart attributes children =
  Html.Lazy.lazy3 render { rowOptions | align = "start" } attributes children

{-| Renders a container as a row with content aligned to center. -}
rowCenter : List Html.Attribute -> List Html.Html -> Html.Html
rowCenter attributes children =
  Html.Lazy.lazy3 render { rowOptions | align = "center" } attributes children

{-| Renders a container as a row with content aligned to end. -}
rowEnd : List Html.Attribute -> List Html.Html -> Html.Html
rowEnd attributes children =
  Html.Lazy.lazy3 render { rowOptions | align = "end" } attributes children

{-| Renders a container as a column. -}
column : List Html.Attribute -> List Html.Html -> Html.Html
column attributes children =
  Html.Lazy.lazy3 render columnOptions attributes children

{-| Renders a container as a column with content aligned to start. -}
columnStart : List Html.Attribute -> List Html.Html -> Html.Html
columnStart attributes children =
  Html.Lazy.lazy3 render { columnOptions | align = "start" } attributes children

{-| Renders a container as a column with content aligned to center. -}
columnCenter : List Html.Attribute -> List Html.Html -> Html.Html
columnCenter attributes children =
  Html.Lazy.lazy3 render { columnOptions | align = "center" } attributes children

{-| Renders a container as a column with content aligned to end. -}
columnEnd : List Html.Attribute -> List Html.Html -> Html.Html
columnEnd attributes children =
  Html.Lazy.lazy3 render { columnOptions | align = "end" } attributes children

{-| Renders a container without lazy. -}
render : Model -> List Html.Attribute -> List Html.Html -> Html.Html
render model attributes children =
  node "ui-container" ([classes model] ++ attributes) children

-- Returns classes for a container
classes : Model -> Html.Attribute
classes model =
  classList [
    ("direction-" ++ model.direction, True),
    ("align-" ++ model.align, True),
    ("compact", model.compact)
  ]
