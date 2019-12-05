# Mechamarkers for Processing 3

Download Processing 3 [here](https://processing.org/).

Download Mechamarkers app [here]().
<br>
<br>
<br>

## Using Mechamarkers with Processing

Download the folder [mechamarker_processing_boilerplate](mechamarker_processing_boilerplate).

For simple use, edit only with the "Drawing Routine". Other sections contain core functions that listens and parses marker data from the Mechamarkers app.

__Reference__
<br>
<br>

_READING MARKERS:_

| Object/Property | Returns | Use case |
| --- | --- | --- |
| `markers.get(X)` | `Marker` Object for X, where X is the marker ID | `markers.get(0)` returns Marker 0 |
| `markers.get(X).center` | `PVector(x, y)` Marker center point | `markers.get(0).center` returns PVector of Marker 0 center<br>`markers.get(0).center.x` returns x coordinate (`float`) of Marker 0 center<br>`markers.get(0).center.y` returns y coordinate (`float`) of Marker 0 center |
| `markers.get(X).corner` | `PVector(x, y)` Marker top left corner point | `markers.get(0).corner` returns PVector of Marker 0 top left corner<br>`markers.get(0).corner.x` returns x coordinate (`float`) of Marker 0 corner<br>`markers.get(0).corner.y` returns y coordinate (`float`) of Marker 0 corner |
| `markers.get(X).allCorners` | `PVector[]` Array of marker corners from starting from top left and progressing clockwise | `markers.get(0).allCorners[1]` returns Marker 0 top right corner coordinate |
| `markers.get(X).present` | `boolean` true/false is Marker present | `markers.get(0).present` returns `true` if Marker 0 is present and `false` if it is absent |
| `markers.get(X).timeout` | `int` Marker timeout value in milliseconds. If the Marker is detected within this timeframe its `present` property will register as `true`; and vice versa. | `markers.get(0).timeout = 100;` sets Marker 0 timeout to 100ms |
| `markers.get(X).smoothing` | `float` Marker smoothing value between 0.0 to 1.0. The higher the value the more the `center` and `corner` coordinates will be smoothed (with previous coordinates). | `markers.get(0).smoothing = 0.7;` sets Marker 0 smoothing to 0.7. i.e. 70% of the previous coordinate and 30% of the new coordinate will be used to update the `center` and `corner` coordinates. |

<br>
<br>

_READING INPUT GROUPS:_

| Object/Property | Returns | Use case |
| --- | --- | --- |
| `inputGroups.get("group name")` | `InputGroup` Object based on its name | `inputGroups.get("input_group_A")` returns `InputGroup` with the name "_input_group_A_" |
| `inputGroups.get("group name").present` | `boolean` true/false is input group present (based on the anchor `Marker`) | `inputGroups.get("input_group_A").present` returns `true` if input_group_A is present and `false` if it is absent |
| `inputGroups.get("group name").anchor` | `Marker` Object for the input group's anchor | `inputGroups.get("input_group_A").anchor` returns the `Marker` object which is the input_group_A's anchor marker.<br>By extension it also gives access to all `Marker` properties, e.g.  `inputGroups.get("input_group_A").anchor.center` returns the anchor marker's center coordinate. |

<br>
<br>

_READING INPUTS:_

| Object/Property | Returns | Use case |
| --- | --- | --- |
| `inputs.get("group name-input name")` | `Input` Object based on the input group's name + `-` + input's name | `inputs.get("groupA-input1")` returns the `Input` "_input1_" in `InputGroup` "_groupA_" |

<br>
<br>

| Object/Property | Returns |
| --- | --- |
| `inputs.get("group name-input name").type` | `String` of the input's type:<br>_BUTTON, TOGGLE, KNOB, SLIDER_ |
| `inputs.get("group name-input name").present` | `boolean` true/false is input group present (based on the actor `Marker`) |
| `inputs.get("group name-input name").actor` | `Marker` Object for the input's actor |
| `inputs.get("group name-input name").val` | `float` input's value based on its type.<br><br>_BUTTON_: 0.0 to 1.0. Button pressed returns a value closer to 1.0.<br>_TOGGLE_: 0.0 to 1.0. Less than 0.5 for state A and more than 0.5 for state B.<br>_KNOB_: -PI to PI. Rotation of the knob with regard to its anchor.<br>_SLIDER_: 0.0 to 1.0. Slider position along its track from start (0.0) to end (1.0). |
| `inputs.get("group name-input name").dir` | `int` input's movement direction (-1 or 1 or 0) based on its type.<br><br>_BUTTON_: button pressed (1), button released (-1).<br>_TOGGLE_: state B to A (1), state A to B (-1).<br>_KNOB_: clockwise (1), counter-clockwise (-1).<br>_SLIDER_: start to end (1), end to start (-1). |
| `inputs.get("group name-input name").smoothing` | `float` 0.0 to 1.0. input value's smoothing factor. A higher value will result in smoother values over time, i.e. the value is less sensitive to change. |