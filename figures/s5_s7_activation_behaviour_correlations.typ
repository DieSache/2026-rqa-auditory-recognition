#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": ACCURACY, ACTIVATION_EVENT_STROKE, ACTIVATION_LINE_STROKE, ACTIVATION_PANEL_SIZE, ACTIVATION_PATTERN_TEXT_SIZE, ACTIVATION_PATTERN_WIDTH, ACTIVATION_SIG_STROKE, ACTIVATION_SIG_Y_ACCURACY, ACTIVATION_SIG_Y_RT, ACTIVATION_X_LIMITS, ACTIVATION_Y_LIMITS, AXIS_TEXT_DENSITY, AXIS_TEXT_SIZE, CAPTION_GAP, HEADER_MELODY_BADGE_DIAMETER, HEADER_MELODY_BADGE_TEXT_SIZE, PANEL_GAP, REACTION_TIME, color-box, legend-key, melody-badge, portrait-figure
#import "temporal_common.typ": TIME_TICKS, TIME_TICK_VALUES, event-lines, note-axis, round-stroke

#let variance-rows = csv("../output/statistics/network_variance.csv", row-type: dictionary)
#let activation-rows = csv("../output/statistics/activation_behaviour.csv", row-type: dictionary)
#let significance-rows = csv("../output/statistics/activation_behaviour_significance.csv", row-type: dictionary)
#let variance-percent(length, network) = {
  let row = variance-rows.find(row => int(row.melody_length) == length)
  str(calc.round(float(row.at("BN" + str(network))), digits: 1)) + "%"
}

#let condition-columns = (
  (index: 1, label: [Memorized]),
  (index: 2, label: [Early change]),
  (index: 3, label: [Late change]),
)

#let figure-specs = (
  (
    melody: [M3],
    key: "m3",
    length: 3,
    data: activation-rows.filter(row => row.block == "m3"),
    significance: significance-rows.filter(row => row.block == "m3"),
    networks: (1, 2, 3),
    events: (0.000, 0.350, 0.700),
  ),
  (
    melody: [M5],
    key: "m5",
    length: 5,
    data: activation-rows.filter(row => row.block == "m5"),
    significance: significance-rows.filter(row => row.block == "m5"),
    networks: (1, 2, 3),
    events: (0.000, 0.350, 0.700, 1.050, 1.400),
  ),
  (
    melody: [M7],
    key: "m7",
    length: 7,
    data: activation-rows.filter(row => row.block == "m7"),
    significance: significance-rows.filter(row => row.block == "m7"),
    networks: (1, 2, 3),
    events: (0.000, 0.350, 0.700, 1.050, 1.400, 1.750, 2.100),
  ),
)

#let series(data, network, condition, outcome) = {
  let rows = data.filter(row => int(row.network_index) == network and int(row.condition_index) == condition and row.outcome == outcome)
  (
    rows.map(row => float(row.time)),
    rows.map(row => float(row.r)),
  )
}

#let significance-segments(significance, network, condition, outcome) = {
  significance.filter(row => int(row.network_index) == network and int(row.condition_index) == condition and row.outcome == outcome)
}

#let significance-lines(significance, network, condition) = {
  let accuracy = significance-segments(significance, network, condition, "accuracy").map(row => {
    let start = float(row.start_time)
    let end = float(row.end_time)
    if end <= start {
      end = start + 0.012
    }
    lq.line(
      (start, ACTIVATION_SIG_Y_ACCURACY),
      (end, ACTIVATION_SIG_Y_ACCURACY),
      stroke: ACCURACY + ACTIVATION_SIG_STROKE,
      z-index: 5,
    )
  })
  let rt = significance-segments(significance, network, condition, "mean_rt").map(row => {
    let start = float(row.start_time)
    let end = float(row.end_time)
    if end <= start {
      end = start + 0.012
    }
    lq.line(
      (start, ACTIVATION_SIG_Y_RT),
      (end, ACTIVATION_SIG_Y_RT),
      stroke: REACTION_TIME + ACTIVATION_SIG_STROKE,
      z-index: 5,
    )
  })

  accuracy + rt
}

#let panel(spec, network, condition, show-x-labels: false, show-y-labels: false, show-note-axis: false) = {
  let (accuracy-x, accuracy-y) = series(spec.data, network, condition.index, "accuracy")
  let (rt-x, rt-y) = series(spec.data, network, condition.index, "mean_rt")
  let tick-format = if show-x-labels { auto } else { none }
  let y-tick-format = if show-y-labels { auto } else { none }

  lq.diagram(
    width: ACTIVATION_PANEL_SIZE,
    height: ACTIVATION_PANEL_SIZE,
    xlim: ACTIVATION_X_LIMITS,
    ylim: ACTIVATION_Y_LIMITS,
    xlabel: if show-x-labels { text(size: AXIS_TEXT_SIZE)[Time (s)] } else { none },
    ylabel: if show-y-labels { text(size: AXIS_TEXT_SIZE)[$r$] } else { none },
    grid: none,
    xaxis: (
      ticks: if show-x-labels { TIME_TICKS } else { TIME_TICK_VALUES },
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: tick-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    yaxis: (
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: y-tick-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    margin: 2%,
    legend: none,
    bounds: "strict",
    if show-note-axis { note-axis(spec.events, ACTIVATION_X_LIMITS) },
    ..event-lines(spec.events, ACTIVATION_Y_LIMITS, ACTIVATION_EVENT_STROKE),
    lq.hlines(0, stroke: luma(55%) + 0.35pt),
    lq.plot(
      accuracy-x,
      accuracy-y,
      stroke: round-stroke(ACCURACY, ACTIVATION_LINE_STROKE),
      mark: none,
      smooth: true,
      z-index: 2,
    ),
    lq.plot(
      rt-x,
      rt-y,
      stroke: round-stroke(REACTION_TIME, ACTIVATION_LINE_STROKE),
      mark: none,
      smooth: true,
      z-index: 3,
    ),
    ..significance-lines(spec.significance, network, condition.index),
  )
}

#let condition-header(spec, condition) = {
  let plot-center-offset = if condition.index == 1 { 1.85em } else { 0.35em }
  let note-gap-offset = if spec.length == 3 { 0em } else if spec.length == 5 { 0.12em } else { 0.28em }
  box(
    width: ACTIVATION_PANEL_SIZE,
    height: 1.5em,
    align(center + bottom, move(dx: plot-center-offset, dy: -0.1em, condition.label)),
  )
}

#let activation-legend() = {
  stack(
    dir: ttb,
    spacing: 0.15em,
    legend-key(ACCURACY, [Accuracy]),
    legend-key(REACTION_TIME, [Reaction time]),
  )
}

#let activation-header(label) = {
  align(center, grid(
      columns: (auto, auto),
      column-gutter: 1.2em,
      align: left + horizon,
      melody-badge(label, diameter: HEADER_MELODY_BADGE_DIAMETER, text-size: HEADER_MELODY_BADGE_TEXT_SIZE),
      activation-legend(),
    ))
}

#let activation-pattern(spec, network) = {
  lq.diagram(
    width: ACTIVATION_PATTERN_WIDTH,
    height: ACTIVATION_PANEL_SIZE,
    xlim: (0, 1),
    ylim: (0, 1),
    xaxis: none,
    yaxis: none,
    grid: none,
    margin: 0%,
    legend: none,
    bounds: "strict",
    lq.place(
      50%,
      50%,
      {
        image(
          "../output/3_timeseries/activation_pattern_" + spec.key + "_bn_" + str(network) + ".png",
          width: ACTIVATION_PATTERN_WIDTH,
          height: ACTIVATION_PANEL_SIZE,
          fit: "contain",
        )
        place(center + horizon, {
          v(-0.15em)
          text(size: ACTIVATION_PATTERN_TEXT_SIZE, variance-percent(spec.length, network))
        })
      },
      align: center + horizon,
      z-index: 10,
    ),
  )
}

#let activation-grid(spec) = {
  {
    show: lq.layout
    grid(
      columns: 4,
      column-gutter: PANEL_GAP,
      row-gutter: PANEL_GAP,
      align: center + horizon,
      [],
      ..condition-columns.map(condition => condition-header(spec, condition)),
      ..spec.networks.map(network => (
        activation-pattern(spec, network),
        ..condition-columns.map(condition => panel(
            spec,
            network,
            condition,
            show-x-labels: network == spec.networks.last(),
            show-y-labels: condition.index == 1,
            show-note-axis: network == spec.networks.first(),
          )),
      )).flatten(),
    )
  }
}

#let activation-body(spec) = [
  #activation-header(spec.melody)
  #v(0em)
  #align(center, activation-grid(spec))
]

#let ACTIVATION_FIGURE_WIDTH = 47em
#show figure.caption: it => align(center)[
  #block(width: ACTIVATION_FIGURE_WIDTH)[
    #align(left)[
      #it.supplement#counter(figure.where(kind: it.kind)).display(it.numbering)#it.separator#it.body
    ]
  ]
]

#portrait-figure(margin-x: 0em)[
#align(center)[#block(width: ACTIVATION_FIGURE_WIDTH)[#figure(
  {
    activation-body(figure-specs.at(0))
    v(CAPTION_GAP)
  },
  caption: [
    *Activation-behaviour correlations*. Line plots show time-resolved Pearson correlations between network activation and behavioural accuracy or mean RT for each condition family in M3. Rows show BN1--BN3, evaluated for every melody length independently of effective dimensionality, and columns show conditions. Bottom bars mark FDR-corrected significant intervals for #color-box(ACCURACY) accuracy and #color-box(REACTION_TIME) mean RT.
  ],
)<fig:activation-behaviour-m3>]]
]

#pagebreak()
#portrait-figure(margin-x: 0em)[
#align(center)[#block(width: ACTIVATION_FIGURE_WIDTH)[#figure(
  {
    activation-body(figure-specs.at(1))
    v(CAPTION_GAP)
  },
  caption: [
    *Activation-behaviour correlations for M5*. Same layout as @fig:activation-behaviour-m3.
  ],
)<fig:activation-behaviour-m5>]]
]

#pagebreak()
#portrait-figure(margin-x: 0em)[
#align(center)[#block(width: ACTIVATION_FIGURE_WIDTH)[#figure(
  {
    activation-body(figure-specs.at(2))
    v(CAPTION_GAP)
  },
  caption: [
    *Activation-behaviour correlations for M7*. Same layout as @fig:activation-behaviour-m3.
  ],
)<fig:activation-behaviour-m7>]]
]
