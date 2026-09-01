#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": AXIS_TEXT_DENSITY, AXIS_TEXT_SIZE, BEHAVIOUR_PANEL_GAP, CAPTION_GAP, EARLY_CHANGE, HEADER_MELODY_BADGE_DIAMETER, HEADER_MELODY_BADGE_TEXT_SIZE, LATE_CHANGE, MEMORIZED, PANEL_TITLE_SIZE, color-box, melody-badge, portrait-figure

#let PANEL_SIZE = 12.5em
#let POINT_SIZE = 3pt
#let SIGNIFICANCE_ROW_GAP = 0.085
#let SIGNIFICANCE_TICK_HEIGHT = 0.025
#let SIGNIFICANCE_BASE_Y = 1.13
#let PLOT_Y_MIN = -0.02
#let PLOT_Y_MAX = 1.02
#let RESPONSE_HEADER_GAP = 0.7em

#let behaviour-rows = csv("../output/statistics/behaviour_subject.csv", row-type: dictionary)
#let melodies = (
  (length: 3, label: [M3], rows: behaviour-rows.filter(row => row.melody_length == "3")),
  (length: 5, label: [M5], rows: behaviour-rows.filter(row => row.melody_length == "5")),
  (length: 7, label: [M7], rows: behaviour-rows.filter(row => row.melody_length == "7")),
)

#let significance-rows = csv("../output/statistics/behaviour_response_comparisons.csv", row-type: dictionary)

#let responses = (
  (key: "correct", column: "accuracy", title: [Correct proportions]),
  (key: "incorrect", column: "incorrect", title: [Incorrect proportions]),
  (key: "no_response", column: "no_response", title: [No-response proportions]),
)

#let conditions = (
  (index: 1, key: "old", label: [Memorized], color: MEMORIZED),
  (index: 2, key: "early", label: [Early change], color: EARLY_CHANGE),
  (index: 3, key: "late", label: [Late change], color: LATE_CHANGE),
)

#let condition-ticks = conditions.map(condition => (
  condition.index,
  {
    v(0.5em)
    rotate(-20deg, text(size: AXIS_TEXT_SIZE, condition.label))
  },
))
#let condition-tick-values = conditions.map(condition => condition.index)
#let proportion-ticks = (
  (0, text(size: AXIS_TEXT_SIZE)[0]),
  (0.25, text(size: AXIS_TEXT_SIZE)[.25]),
  (0.5, text(size: AXIS_TEXT_SIZE)[.50]),
  (0.75, text(size: AXIS_TEXT_SIZE)[.75]),
  (1, text(size: AXIS_TEXT_SIZE)[1]),
)
#let proportion-tick-values = proportion-ticks.map(((value, _)) => value)

#let values(rows, response, condition) = {
  rows
    .filter(row => int(row.condition_index) == condition.index)
    .map(row => float(row.at(response.column)))
}

#let jitter(row-index, condition-index) = {
  (calc.rem(row-index * 37 + condition-index * 19, 100) / 100 - 0.5) * 0.44
}

#let scatter-data(rows, response, condition) = {
  let xs = ()
  let ys = ()

  for (row-index, row) in rows.filter(row => int(row.condition_index) == condition.index).enumerate() {
    xs.push(condition.index + jitter(row-index, condition.index))
    ys.push(float(row.at(response.column)))
  }

  (xs, ys)
}

#let condition-index(key) = {
  (old: 1, early: 2, late: 3).at(key)
}

#let bracket-order(row) = {
  if row.condition_a == "old" and row.condition_b == "early" {
    0
  } else if row.condition_a == "early" and row.condition_b == "late" {
    1
  } else {
    2
  }
}

#let significance-brackets(melody, response) = {
  significance-rows
    .filter(row => row.comparison_family == "condition" and int(row.melody_length_a) == melody.length and row.response_a == response.key and row.display_significance != "")
    .sorted(key: bracket-order)
    .enumerate()
    .map(((row-index, row)) => {
      let x1 = condition-index(row.condition_a)
      let x2 = condition-index(row.condition_b)
      let y = SIGNIFICANCE_BASE_Y + row-index * SIGNIFICANCE_ROW_GAP
      let tick-y = y - SIGNIFICANCE_TICK_HEIGHT
      let color = black

      (
        lq.line((x1, tick-y), (x1, y), stroke: color + 0.8pt, clip: false, z-index: 20),
        lq.line((x1, y), (x2, y), stroke: color + 0.8pt, clip: false, z-index: 20),
        lq.line((x2, y), (x2, tick-y), stroke: color + 0.8pt, clip: false, z-index: 20),
        lq.place(
          (x1 + x2) / 2,
          y + 0.012,
          align: center + bottom,
          text(size: 7pt, fill: color)[#row.display_significance],
          clip: false,
          z-index: 21,
        ),
      )
    })
    .flatten()
}

#let panel(melody, response, show-x-labels: false, show-y-labels: false) = {
  let x-format = if show-x-labels { auto } else { none }
  let y-format = if show-y-labels { auto } else { none }

  lq.diagram(
    width: PANEL_SIZE,
    height: PANEL_SIZE,
    xlim: (0.5, 3.5),
    ylim: (PLOT_Y_MIN, PLOT_Y_MAX),
    grid: none,
    xaxis: (
      ticks: if show-x-labels { condition-ticks } else { condition-tick-values },
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: x-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    yaxis: (
      ticks: if show-y-labels { proportion-ticks } else { proportion-tick-values },
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: y-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    margin: 2%,
    legend: none,
    bounds: "relaxed",
    ..conditions.map(condition => lq.boxplot(
        values(melody.rows, response, condition),
        x: condition.index,
        width: 38%,
        fill: white,
        stroke: black + 0.45pt,
        median: black,
        outliers: none,
        z-index: 2,
      )),
    ..conditions.map(condition => {
      let (xs, ys) = scatter-data(melody.rows, response, condition)
      lq.scatter(
        xs,
        ys,
        size: POINT_SIZE,
        color: condition.color,
        alpha: 62%,
        stroke: none,
        z-index: 3,
      )
    }),
    ..significance-brackets(melody, response),
  )
}

#let melody-header = {
  show: lq.layout
  grid(
    columns: 3,
    column-gutter: BEHAVIOUR_PANEL_GAP,
    align: center + horizon,
    ..melodies.map(melody => box(
        width: PANEL_SIZE,
        align(center, melody-badge(
            melody.label,
            diameter: HEADER_MELODY_BADGE_DIAMETER,
            text-size: HEADER_MELODY_BADGE_TEXT_SIZE,
          )),
      )),
  )
}

#let response-row(response, response-index) = stack(
  dir: ttb,
  spacing: RESPONSE_HEADER_GAP,
  align(center, text(size: PANEL_TITLE_SIZE, weight: "bold", response.title)),
  {
    show: lq.layout
    grid(
      columns: 3,
      column-gutter: BEHAVIOUR_PANEL_GAP,
      align: center + horizon,
      ..melodies.enumerate().map(((melody-index, melody)) => panel(
          melody,
          response,
          show-x-labels: response-index == responses.len() - 1,
          show-y-labels: melody-index == 0,
        )),
    )
  },
)

#portrait-figure(margin-x: 1.5em)[
#figure(
  {
    align(center, {
      stack(
        dir: ttb,
        spacing: BEHAVIOUR_PANEL_GAP,
        melody-header,
        ..responses.enumerate().map(((response-index, response)) => response-row(response, response-index)),
      )
    })
    v(CAPTION_GAP)
  },
  caption: [
    *Behavioural response proportions across melody length and condition*. Columns show M3, M5, and M7 melodies, and rows show correct, incorrect, and no-response proportions. Boxplots and subject-level points show distributions for #color-box(MEMORIZED) memorized (M), #color-box(EARLY_CHANGE) early-change, and #color-box(LATE_CHANGE) late-change trials. Brackets mark FDR-corrected condition comparisons. $*p < .05$, $**p < .01$, $***p < .001$.
  ],
)<fig:behaviour-response-proportions>
]
