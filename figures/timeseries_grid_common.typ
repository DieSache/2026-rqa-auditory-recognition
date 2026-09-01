#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": AXIS_TEXT_DENSITY, AXIS_TEXT_SIZE, CAPTION_GAP, EARLY_CHANGE, HEADER_MELODY_BADGE_DIAMETER, HEADER_MELODY_BADGE_TEXT_SIZE, LATE_CHANGE, MEMORIZED, PANEL_GAP, TIMESERIES_EVENT_STROKE, TIMESERIES_FILL_ALPHA, TIMESERIES_LINE_STROKE, TIMESERIES_PANEL_HEIGHT, TIMESERIES_PANEL_WIDTH, TIMESERIES_PATTERN_TEXT_SIZE, TIMESERIES_PATTERN_WIDTH, TIMESERIES_SIG_STROKE, TIMESERIES_SIG_Y_EARLY, TIMESERIES_SIG_Y_LATE, TIMESERIES_X_LIMITS, TIMESERIES_Y_LIMITS, color-box, legend-key, melody-badge, portrait-figure
#import "temporal_common.typ": TIME_TICKS, TIME_TICK_VALUES, axis-label, event-lines, note-axis

#let conditions = (
  (label: [Early change], mean: "NTE", ste: "NTE_STE", color: EARLY_CHANGE),
  (label: [Late change], mean: "NTL", ste: "NTL_STE", color: LATE_CHANGE),
  (label: [M], mean: "M", ste: "M_STE", color: MEMORIZED),
)

#let melody-specs = (
  (key: "m3", length: 3, label: [M3], early: [T2], late: [T3], events: (0.000, 0.350, 0.700)),
  (key: "m5", length: 5, label: [M5], early: [T3], late: [T5], events: (0.000, 0.350, 0.700, 1.050, 1.400)),
  (key: "m7", length: 7, label: [M7], early: [T5], late: [T7], events: (0.000, 0.350, 0.700, 1.050, 1.400, 1.750, 2.100)),
)

#let variance-explained = csv("../output/statistics/network_variance.csv", row-type: dictionary)

#let networks = (
  (index: 1, label: [BN 1]),
  (index: 2, label: [BN 2]),
  (index: 3, label: [BN 3]),
)

#let y-ticks = (
  (-1000, axis-label[-1000]),
  (-500, axis-label[-500]),
  (0, axis-label[0]),
  (500, axis-label[500]),
  (1000, axis-label[1000]),
)

#let y-tick-values = y-ticks.map(((value, _)) => value)

#let values(rows, key) = {
  rows.map(row => float(row.at(key)))
}

#let format-percent(value) = {
  str(calc.round(value * 10) / 10) + "%"
}

#let series(rows, condition) = {
  let xs = values(rows, "Time")
  let mean = values(rows, condition.mean)
  let ste = values(rows, condition.ste)
  let lower = mean.zip(ste).map(((m, s)) => m - s)
  let upper = mean.zip(ste).map(((m, s)) => m + s)
  (xs, mean, lower, upper)
}

#let activation-pattern(spec, network) = {
  let row = variance-explained.find(row => int(row.melody_length) == spec.length)
  let variance = float(row.at("BN" + str(network.index)))

  box(
    width: TIMESERIES_PATTERN_WIDTH,
    {
      image(
        "../output/3_timeseries/activation_pattern_" + spec.key + "_bn_" + str(network.index) + ".png",
        width: TIMESERIES_PATTERN_WIDTH,
      )
      place(
        center + horizon,
        text(size: TIMESERIES_PATTERN_TEXT_SIZE, format-percent(variance)),
        dy: -2%,
      )
    },
  )
}

#let activation-pattern-place(spec, network) = {
  lq.place(
    3%,
    3%,
    activation-pattern(spec, network),
    align: left + top,
    z-index: 10,
  )
}

#let condition-plots(rows, condition) = {
  let (xs, mean, lower, upper) = series(rows, condition)
  (
    lq.fill-between(
      xs,
      lower,
      y2: upper,
      fill: condition.color.transparentize(TIMESERIES_FILL_ALPHA),
      stroke: none,
      smooth: true,
      z-index: 2,
    ),
    lq.plot(
      xs,
      mean,
      stroke: condition.color + TIMESERIES_LINE_STROKE,
      mark: none,
      smooth: true,
      z-index: 3,
    ),
  )
}

#let significance-windows(correction, spec, network, condition) = {
  csv(
    "../output/3_timeseries/" + correction + "/significance_windows_" + spec.key + "_bn_" + str(network.index) + ".csv",
    row-type: dictionary,
  ).filter(row => row.condition == condition)
}

#let significance-lines(correction, spec, network) = {
  let draw-window(row, color, y) = {
    let start = float(row.start)
    let end = float(row.end)
    if end <= start {
      end = start + 0.012
    }
    lq.line(
      (start, y),
      (end, y),
      stroke: color + TIMESERIES_SIG_STROKE,
      z-index: 8,
    )
  }

  (
    significance-windows(correction, spec, network, "NTE").map(row => draw-window(row, EARLY_CHANGE, TIMESERIES_SIG_Y_EARLY)) +
    significance-windows(correction, spec, network, "NTL").map(row => draw-window(row, LATE_CHANGE, TIMESERIES_SIG_Y_LATE))
  )
}

#let melody-legend(spec) = {
  stack(
    dir: ttb,
    spacing: 0.15em,
    legend-key(MEMORIZED, [M]),
    legend-key(EARLY_CHANGE, [N#spec.early]),
    legend-key(LATE_CHANGE, [N#spec.late]),
  )
}

#let melody-title(spec) = {
  box(width: TIMESERIES_PANEL_WIDTH, align(center, grid(
        columns: (auto, auto),
        column-gutter: 0.8em,
        align: left + horizon,
        melody-badge(spec.label, diameter: HEADER_MELODY_BADGE_DIAMETER, text-size: HEADER_MELODY_BADGE_TEXT_SIZE),
        melody-legend(spec),
      )))
}

#let timeseries-panel(correction, spec, network, show-x-labels: false, show-y-labels: false, show-note-axis: false) = {
  let tick-format = if show-x-labels { auto } else { none }
  let y-tick-format = if show-y-labels { auto } else { none }
  let rows = csv("../output/3_timeseries/" + spec.key + "_bn_" + str(network.index) + ".csv", row-type: dictionary)

  lq.diagram(
    width: TIMESERIES_PANEL_WIDTH,
    height: TIMESERIES_PANEL_HEIGHT,
    title: if show-note-axis { lq.title(melody-title(spec), dy: -1.2em, pad: 0.35em) } else { none },
    xlim: TIMESERIES_X_LIMITS,
    ylim: TIMESERIES_Y_LIMITS,
    xlabel: if show-x-labels { text(size: AXIS_TEXT_SIZE)[Time (s)] } else { none },
    ylabel: if show-y-labels { text(size: AXIS_TEXT_SIZE)[Amplitude / BN #network.index] } else { none },
    grid: none,
    xaxis: (
      ticks: if show-x-labels { TIME_TICKS } else { TIME_TICK_VALUES },
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: tick-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    yaxis: (
      ticks: if show-y-labels { y-ticks } else { y-tick-values },
      tick-args: (density: AXIS_TEXT_DENSITY),
      format-ticks: y-tick-format,
      subticks: none,
      mirror: (ticks: false, tick-labels: false),
    ),
    margin: 2%,
    legend: none,
    bounds: "strict",
    if show-note-axis { note-axis(spec.events, TIMESERIES_X_LIMITS) },
    ..event-lines(spec.events, TIMESERIES_Y_LIMITS, TIMESERIES_EVENT_STROKE),
    lq.hlines(0, stroke: luma(55%) + 0.35pt),
    activation-pattern-place(spec, network),
    ..significance-lines(correction, spec, network),
    ..conditions.map(condition => condition-plots(rows, condition)).flatten(),
  )
}

#let timeseries-grid(correction) = {
  align(center, {
    show: lq.layout
    grid(
      columns: 3,
      column-gutter: PANEL_GAP,
      row-gutter: PANEL_GAP,
      ..networks.map(network => melody-specs.map(spec => timeseries-panel(
            correction,
            spec,
            network,
            show-x-labels: network.index == 3,
            show-y-labels: spec.key == "m3",
            show-note-axis: network.index == 1,
          ))).flatten(),
    )
  })
}

#let timeseries-figure(correction, caption-title: [Time series]) = {
  portrait-figure(margin-x: 2em)[
    #let body = {
      timeseries-grid(correction)
      v(CAPTION_GAP)
    }
    #let caption = [
      *#caption-title*. Lines show mean activation time courses for #color-box(MEMORIZED) memorized (M), #color-box(EARLY_CHANGE) early-change, and #color-box(LATE_CHANGE) late-change melodies across brain-network clusters. Shaded bands show +/- standard error, dashed lines and musical notes mark tone onsets, embedded images show activation patterns with variance explained, and bottom bars mark significant early- and late-change windows.
    ]
    #if correction == "cluster" {
      [#figure(body, caption: caption)<fig:activation-time-series>]
    } else {
      [#figure(body, caption: caption)<fig:activation-time-series-fdr>]
    }
  ]
}
