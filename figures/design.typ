#let CORRECT = rgb(37, 99, 235)
#let INCORRECT = rgb(234, 88, 12)
#let NO_RESPONSE = rgb(107, 114, 128)
#let ACCURACY = rgb(0, 158, 115)
#let REACTION_TIME = rgb(204, 121, 167)
#let MEMORIZED = black
#let EARLY_CHANGE = CORRECT
#let LATE_CHANGE = INCORRECT
#let EXCLUSION = rgb(213, 0, 0)

#let PANEL_GAP = 0.4em
#let BEHAVIOUR_PANEL_GAP = 1em
#let RQA_PANEL_GAP = 1em
#let CAPTION_GAP = 0.75em
#let AXIS_TEXT_SIZE = 9.5pt
#let AXIS_TEXT_DENSITY = 55%
#let PANEL_TITLE_SIZE = 11pt
#let MELODY_BADGE_DIAMETER = 1.8em
#let MELODY_BADGE_TEXT_SIZE = 9.5pt
#let HEADER_MELODY_BADGE_DIAMETER = 2.2em
#let HEADER_MELODY_BADGE_TEXT_SIZE = 10.5pt
#let TONE_MARKER_TEXT_SIZE = 9pt

#let TIMESERIES_PANEL_WIDTH = 15em
#let TIMESERIES_PANEL_HEIGHT = 15em
#let TIMESERIES_PATTERN_WIDTH = 5.5em
#let TIMESERIES_PATTERN_TEXT_SIZE = 6.5pt
#let TIMESERIES_X_LIMITS = (-0.1, 3.4)
#let TIMESERIES_Y_LIMITS = (-1500, 1500)
#let TIMESERIES_LINE_STROKE = 0.55pt
#let TIMESERIES_FILL_ALPHA = 82%
#let TIMESERIES_EVENT_STROKE = (paint: luma(0%), thickness: 0.35pt, dash: "dashed")
#let TIMESERIES_SIG_STROKE = 2pt
#let TIMESERIES_SIG_Y_EARLY = -1400
#let TIMESERIES_SIG_Y_LATE = -1300

#let ACTIVATION_PANEL_SIZE = 11.5em
#let ACTIVATION_PATTERN_WIDTH = 7.2em
#let ACTIVATION_PATTERN_TEXT_SIZE = 9pt
#let ACTIVATION_Y_LIMITS = (-0.7, 0.7)
#let ACTIVATION_X_LIMITS = (-0.1, 3.4)
#let ACTIVATION_SIG_Y_ACCURACY = -0.62
#let ACTIVATION_SIG_Y_RT = -0.55
#let ACTIVATION_LINE_STROKE = 0.35pt
#let ACTIVATION_SIG_STROKE = 2pt
#let ACTIVATION_EVENT_STROKE = (paint: luma(0%), thickness: 0.5pt, dash: "dashed")

#let CONDITIONS = (
  (index: 1, key: "old", short: [M], label: [Memorized], color: MEMORIZED),
  (index: 2, key: "early", short: [Early change], label: [Early change], color: EARLY_CHANGE),
  (index: 3, key: "late", short: [Late change], label: [Late change], color: LATE_CHANGE),
)

#let RESPONSE_CATEGORIES = (
  (key: "right", label: [correct], color: CORRECT),
  (key: "wrong", label: [incorrect], color: INCORRECT),
  (key: "neutral", label: [no response], color: NO_RESPONSE),
)

#let RQA_METRICS = (
  (key: "RR", label: [RR]),
  (key: "L", label: [L]),
  (key: "DET", label: [DET]),
  (key: "ENTR", label: [ENTR]),
  (key: "TT", label: [TT]),
  (key: "LAM", label: [LAM]),
  (key: "V_max", label: [$bold(V_"max")$]),
  (key: "DIV", label: [DIV]),
)

#let color-box(fill) = box(radius: 10%, fill: fill, height: 0.6em, width: 0.6em)

#let color-gradient(value, min, max, low: CORRECT, high: INCORRECT) = {
  let fraction = (value - min) / (max - min)
  let low-components = low.components()
  let high-components = high.components()
  rgb(
    low-components.at(0) * (1 - fraction) + high-components.at(0) * fraction,
    low-components.at(1) * (1 - fraction) + high-components.at(1) * fraction,
    low-components.at(2) * (1 - fraction) + high-components.at(2) * fraction,
  )
}

#let melody-badge(label, diameter: MELODY_BADGE_DIAMETER, text-size: MELODY_BADGE_TEXT_SIZE) = circle(
  width: diameter,
  height: diameter,
  stroke: black + 0.6pt,
  inset: 0pt,
)[
  #box(width: 100%, height: 100%)[
    #align(center + horizon, text(size: text-size, label))
  ]
]

#let legend-key(color, label) = grid(
  columns: (0.6em, auto),
  column-gutter: 0.35em,
  align: left + horizon,
  color-box(color),
  label,
)

#let condition-legend(items: CONDITIONS, direction: ttb) = stack(
  dir: direction,
  spacing: 0.15em,
  ..items.map(item => legend-key(item.color, item.label)),
)

#let figure-body(body) = {
  body
  v(CAPTION_GAP)
}

#let portrait-figure(body, margin-x: auto) = {
  set page(flipped: false, margin: (x: margin-x, top: 0em, bottom: 0em))
  set par.line(numbering: none)
  v(1fr)
  body
  v(1fr)
}

#let landscape-figure(body, margin-x: auto) = {
  set page(flipped: true, margin: (x: margin-x, top: 0em, bottom: 0em))
  set par.line(numbering: none)
  v(1fr)
  body
  v(1fr)
}
