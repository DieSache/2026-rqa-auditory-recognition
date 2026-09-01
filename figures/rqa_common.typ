#import "@preview/cetz:0.5.2"
#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": AXIS_TEXT_DENSITY, PANEL_TITLE_SIZE, RQA_METRICS, color-gradient, melody-badge, NO_RESPONSE

#let HEATMAP_TILE_SIZE = 3.7em
#let HEATMAP_PADDING = 3em
#let HEATMAP_MIN_R = -0.6
#let HEATMAP_MAX_R = 0.6
#let HEATMAP_ROW_LABEL_X = -1.6em
#let HEATMAP_TITLE_OFFSET = 0.55em
#let HEATMAP_CELL_TEXT_SIZE = 8pt

#let DISTRIBUTION_PANEL_SIZE = 13em
#let DISTRIBUTION_POINT_SIZE = 3pt
#let DISTRIBUTION_POINT_ALPHA = 62%
#let DISTRIBUTION_VIOLIN_WIDTH = 0.72
#let DISTRIBUTION_BOX_WIDTH = 38%
#let DISTRIBUTION_BOX_FILL = white
#let DISTRIBUTION_BOX_STROKE = black + 0.45pt
#let DISTRIBUTION_TICK_TEXT_SIZE = 9.5pt

#let rqa-heatmap-width(columns) = columns.len() * HEATMAP_TILE_SIZE
#let rqa-heatmap-height(rows) = rows.len() * HEATMAP_TILE_SIZE
#let rqa-format-value(value, significant: false) = str(calc.round(value * 100) / 100) + if significant { "*" } else { "" }

#let draw-rqa-heatmap(origin, title, rows, columns, values, significant, circle-row-labels: false, show-row-labels: true, show-column-labels: true, column-label-position: bottom, circle-column-labels: false, show-column-ticks: true, show-title: true) = {
  import cetz.draw: *
  let (origin-x, origin-y) = origin
  let width = rqa-heatmap-width(columns)
  let height = rqa-heatmap-height(rows)

  let title-y = origin-y + height + if show-column-labels and column-label-position == top { 3.1em } else { HEATMAP_TITLE_OFFSET }
  if show-title {
    content((origin-x + width / 2, title-y), anchor: "south", text(weight: "bold", size: PANEL_TITLE_SIZE, title))
  }

  for (row-index, row-label) in rows.enumerate() {
    let label-y = origin-y + height - (row-index + 0.5) * HEATMAP_TILE_SIZE
    if show-row-labels {
      if circle-row-labels {
        content((origin-x + HEATMAP_ROW_LABEL_X, label-y), anchor: "center", melody-badge(row-label))
      } else {
        content((origin-x + HEATMAP_ROW_LABEL_X, label-y), anchor: "east", row-label)
      }
    }
    for (col-index, _) in columns.enumerate() {
      let value = values.at(row-index).at(col-index)
      let is-significant = significant.at(row-index).at(col-index)
      let x = origin-x + col-index * HEATMAP_TILE_SIZE
      let y = origin-y + height - (row-index + 1) * HEATMAP_TILE_SIZE
      let fill = if is-significant { color-gradient(value, HEATMAP_MIN_R, HEATMAP_MAX_R) } else { NO_RESPONSE }
      rect((x, y), (x + HEATMAP_TILE_SIZE, y + HEATMAP_TILE_SIZE), fill: fill)
      content((x + HEATMAP_TILE_SIZE / 2, y + HEATMAP_TILE_SIZE / 2), text(fill: white, size: HEATMAP_CELL_TEXT_SIZE)[#rqa-format-value(value, significant: is-significant)])
    }
  }
  rect((origin-x, origin-y), (origin-x + width, origin-y + height), fill: none)
  if show-column-labels {
    for (col-index, col-label) in columns.enumerate() {
      let x = origin-x + (col-index + 0.5) * HEATMAP_TILE_SIZE
      if column-label-position == top {
        if show-column-ticks {
          line((x, origin-y + height), (x, origin-y + height + 0.45em))
        }
        content(
          (x, origin-y + height + 1.45em),
          anchor: "center",
          if circle-column-labels { melody-badge(col-label) } else { col-label },
        )
      } else {
        line((x, origin-y), (x, origin-y - 0.5em))
        content((x, origin-y - 1.2em), anchor: "north", col-label)
      }
    }
  }
}

#let metric-values(rows, metric) = rows.filter(row => row.metric == metric).map(row => float(row.value))
#let metric-limits(rows, metric) = {
  let values = metric-values(rows, metric)
  let minimum = calc.min(..values)
  let maximum = calc.max(..values)
  let padding = (maximum - minimum) * 0.06
  (minimum - padding, maximum + padding)
}
#let deterministic-jitter(participant-index, secondary-index, group-index) = (calc.rem(participant-index * 37 + secondary-index * 23 + group-index * 17, 100) / 100 - 0.5) * 0.22
#let group-values(rows, metric, group-index) = rows.filter(row => row.metric == metric and int(row.plot_group_index) == group-index).map(row => float(row.value))

#let distribution-panel(rows, metric, groups, panel-size: DISTRIBUTION_PANEL_SIZE, xlabel: none, ylabel: auto, ticks: auto, extra-ticks: (), show-x-tick-labels: true, x-position: bottom, title-pad: none, violin: false, scatter-by-group: true) = {
  let group-indices = groups.map(group => group.index)
  let xs = rows.filter(row => row.metric == metric.key).map(row => {
    let index = int(row.plot_group_index)
    index + deterministic-jitter(int(row.participant_index), int(row.condition_index), index)
  })
  let ys = rows.filter(row => row.metric == metric.key).map(row => float(row.value))
  let distributions = if violin {
    (lq.violin(
      ..groups.map(group => group-values(rows, metric.key, group.index)),
      x: group-indices,
      width: DISTRIBUTION_VIOLIN_WIDTH,
      fill: NO_RESPONSE.transparentize(35%),
      stroke: none,
      median: black,
      boxplot: (fill: DISTRIBUTION_BOX_FILL, stroke: DISTRIBUTION_BOX_STROKE, width: DISTRIBUTION_BOX_WIDTH),
      z-index: 1,
    ),)
  } else {
    groups.map(group => lq.boxplot(group-values(rows, metric.key, group.index), x: group.index, width: DISTRIBUTION_BOX_WIDTH, fill: DISTRIBUTION_BOX_FILL, stroke: DISTRIBUTION_BOX_STROKE, median: black, outliers: none, z-index: 1))
  }
  let scatters = if scatter-by-group {
    groups.map(group => {
      let group-rows = rows.filter(row => row.metric == metric.key and int(row.plot_group_index) == group.index)
      lq.scatter(
        group-rows.map(row => group.index + deterministic-jitter(int(row.participant_index), int(row.condition_index), group.index)),
        group-rows.map(row => float(row.value)),
        size: DISTRIBUTION_POINT_SIZE,
        color: group.color,
        alpha: DISTRIBUTION_POINT_ALPHA,
        stroke: none,
        z-index: 3,
      )
    })
  } else {
    (lq.scatter(xs, ys, size: DISTRIBUTION_POINT_SIZE, color: black, alpha: DISTRIBUTION_POINT_ALPHA, stroke: none, z-index: 3),)
  }
  lq.diagram(
    width: panel-size,
    height: panel-size,
    title: if title-pad == none {
      text(size: PANEL_TITLE_SIZE, weight: "bold", metric.label)
    } else {
      lq.title(text(size: PANEL_TITLE_SIZE, weight: "bold", metric.label), pad: title-pad)
    },
    xlim: (group-indices.first() - 0.55, group-indices.last() + 0.55),
    ylim: metric-limits(rows, metric.key),
    xlabel: xlabel,
    grid: none,
    xaxis: (position: x-position, ticks: ticks, extra-ticks: extra-ticks, format-ticks: if show-x-tick-labels { auto } else { none }, subticks: none, mirror: (ticks: false, tick-labels: false)),
    yaxis: (tick-args: (density: 70%), subticks: none, mirror: (ticks: false, tick-labels: false)),
    margin: 2%,
    legend: none,
    bounds: "strict",
    ..distributions,
    ..scatters,
  )
}
