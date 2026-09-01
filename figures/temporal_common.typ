#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": AXIS_TEXT_SIZE, TONE_MARKER_TEXT_SIZE

#let axis-label(value) = text(size: AXIS_TEXT_SIZE, value)
#let TIME_TICKS = (
  (0.0, axis-label[0]),
  (0.5, axis-label[0.5]),
  (1.0, axis-label[1]),
  (1.5, axis-label[1.5]),
  (2.0, axis-label[2]),
  (2.5, axis-label[2.5]),
  (3.0, axis-label[3]),
)
#let TIME_TICK_VALUES = TIME_TICKS.map(((value, _)) => value)

#let note-axis(events, x-limits) = lq.axis(
  kind: "x",
  position: top,
  lim: x-limits,
  ticks: events.map(time => (time, text(size: TONE_MARKER_TEXT_SIZE)[♪])),
  subticks: none,
  mirror: false,
)

#let event-lines(events, y-limits, stroke) = events.map(time => lq.line(
  (time, y-limits.at(0)),
  (time, y-limits.at(1)),
  stroke: stroke,
  z-index: 1,
))

#let round-stroke(color, thickness) = (paint: color, thickness: thickness, cap: "round")
