#import "@preview/cetz:0.5.2"
#import "design.typ": AXIS_TEXT_SIZE, CONDITIONS, CORRECT, INCORRECT, NO_RESPONSE, RESPONSE_CATEGORIES, melody-badge,

#let BAR_WIDTH = 4em
#let BAR_PADDING = 1.5em
#let BAR_HEIGHT = 18em
#let GROUP_PADDING = 4.5em
#let SIDE_PADDING = 2.5em
#let TICK_HEIGHT = 0.5em
#let CONDITION_LABEL_Y = -1.2em
#let SIGNIFICANCE_Y = BAR_HEIGHT + 1em
#let SIGNIFICANCE_ROW_GAP = 1.5em
#let SIGNIFICANCE_TICK_HEIGHT = 0.5em

#let SIGNIFICANCE_COLORS = (overall: black, right: CORRECT, wrong: INCORRECT)
#let SIGNIFICANCE_KINDS = ("overall", "right", "wrong")
#let CONDITION_INDICES = (old: 0, early: 1, late: 2)

#let group-width() = BAR_WIDTH * 3 + BAR_PADDING * 2
#let figure-width(group-count) = group-count * (group-width() + GROUP_PADDING) - GROUP_PADDING + SIDE_PADDING * 2

#let count-significance(significance) = {
  let total = 0
  for kind in SIGNIFICANCE_KINDS {
    if kind in significance { total += significance.at(kind).len() }
  }
  total
}

#let group-index-x(index) = SIDE_PADDING + index * (group-width() + GROUP_PADDING)
#let condition-x(group-x, condition-key) = group-x + CONDITION_INDICES.at(condition-key) * (BAR_WIDTH + BAR_PADDING)
#let condition-center-x(group-x, condition-key) = condition-x(group-x, condition-key) + BAR_WIDTH / 2

#let draw-baseline(group-count) = {
  import cetz.draw: *
  line((0, 0), (figure-width(group-count), 0))
}

#let draw-condition-tick-label(x, label) = {
  import cetz.draw: *
  let center-x = x + BAR_WIDTH / 2
  line((center-x, 0), (center-x, -TICK_HEIGHT))
  content((center-x, CONDITION_LABEL_Y), angle: 20deg, anchor: "north", text(size: AXIS_TEXT_SIZE, label))
}

#let draw-melody-group-label(x, y, label) = {
  import cetz.draw: *
  content((x + group-width() / 2, y), anchor: "south", melody-badge(label))
}

#let draw-significance-bar(xs, y, level, color: black) = {
  import cetz.draw: *
  let left = calc.min(..xs)
  let right = calc.max(..xs)
  let sorted-xs = xs.sorted()
  let tick-y = y + SIGNIFICANCE_TICK_HEIGHT
  let points = ()
  for (index, x) in sorted-xs.enumerate() {
    if index == 0 {
      points.push((x, y))
      points.push((x, tick-y))
    } else {
      points.push((x, tick-y))
      points.push((x, y))
      if index < sorted-xs.len() - 1 { points.push((x, tick-y)) }
    }
  }
  line(..points, stroke: color + 1pt)
  content((left + (right - left) / 2, tick-y), anchor: "south", text(fill: color, level))
}
