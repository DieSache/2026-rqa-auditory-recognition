#import "@preview/cetz:0.5.2"
#import "design.typ": CAPTION_GAP, CORRECT, INCORRECT, NO_RESPONSE, color-box, portrait-figure
#import "rqa_common.typ": draw-rqa-heatmap, rqa-heatmap-height, rqa-heatmap-width

#let condition-correlation-rows = csv("../output/5_rqa_correlations/by_cell.csv", row-type: dictionary)
#let columns = ([M3], [M5], [M7])
#let row-labels = ([Memorized], [Early change], [Late change])
#let melody-lengths = (3, 5, 7)
#let condition-indices = (1, 2, 3)
#let HEATMAP_HEIGHT = rqa-heatmap-height(row-labels)
#let HEATMAP_WIDTH = rqa-heatmap-width(columns)
#let S5_HEATMAP_PADDING = 1em
#let S5_PANEL_PADDING = 2em
#let S5_LEFT_OFFSET = 9em
#let METRIC_ROW_HEIGHT = HEATMAP_HEIGHT + S5_HEATMAP_PADDING

#let condition-correlation-row(metric, outcome, condition-index, melody-length) = {
  let matches = condition-correlation-rows.filter(row => (
    row.metric == metric
    and row.outcome == outcome
    and int(row.condition_index) == condition-index
    and int(row.melody_length) == melody-length
  ))
  matches.first()
}

#let condition-values(metric, outcome) = condition-indices.map(condition-index => (
  melody-lengths.map(melody-length => float(condition-correlation-row(metric, outcome, condition-index, melody-length).r))
))

#let condition-significance(metric, outcome) = condition-indices.map(condition-index => (
  melody-lengths.map(melody-length => float(condition-correlation-row(metric, outcome, condition-index, melody-length).p_value_fdr_8way) < 0.05)
))

#let metric-data(metric-key, metric-label) = (
  metric: metric-label,
  accuracy: condition-values(metric-key, "accuracy"),
  accuracy-significant: condition-significance(metric-key, "accuracy"),
  rt: condition-values(metric-key, "mean_rt"),
  rt-significant: condition-significance(metric-key, "mean_rt"),
)

#let draw-metric-row(origin-y, metric, accuracy, accuracy-significant, rt, rt-significant, show-column-labels: false) = {
  import cetz.draw: *

  content((0em, origin-y + HEATMAP_HEIGHT / 2), anchor: "east", text(weight: "bold")[#metric])
  draw-rqa-heatmap(
    (S5_LEFT_OFFSET, origin-y),
    [Accuracy],
    row-labels,
    columns,
    accuracy,
    accuracy-significant,
    show-column-labels: show-column-labels,
    show-title: show-column-labels,
    column-label-position: top,
    circle-column-labels: true,
    show-column-ticks: false,
  )
  draw-rqa-heatmap(
    (S5_LEFT_OFFSET + HEATMAP_WIDTH + S5_PANEL_PADDING, origin-y),
    [Mean RT],
    row-labels,
    columns,
    rt,
    rt-significant,
    show-row-labels: false,
    show-column-labels: show-column-labels,
    show-title: show-column-labels,
    column-label-position: top,
    circle-column-labels: true,
    show-column-ticks: false,
  )
}

#let first-page-metrics = (
  metric-data("RR", [RR]),
  metric-data("L", [L]),
  metric-data("DET", [DET]),
  metric-data("ENTR", [ENTR]),
)

#let second-page-metrics = (
  metric-data("TT", [TT]),
  metric-data("LAM", [LAM]),
  metric-data("V_max", [$bold(V_"max")$]),
  metric-data("DIV", [DIV]),
)

#let draw-page(metrics) = {
  align(center, cetz.canvas({
      let y4 = 0em
      let y3 = y4 + METRIC_ROW_HEIGHT
      let y2 = y3 + METRIC_ROW_HEIGHT
      let y1 = y2 + METRIC_ROW_HEIGHT
      let ys = (y1, y2, y3, y4)

      for (index, metric-data) in metrics.enumerate() {
        draw-metric-row(
          ys.at(index),
          metric-data.metric,
          metric-data.accuracy,
          metric-data.accuracy-significant,
          metric-data.rt,
          metric-data.rt-significant,
          show-column-labels: index == 0,
        )
      }
    }))
}

#portrait-figure[
#figure(
  {
    draw-page(first-page-metrics)
    v(CAPTION_GAP)
  },
  caption: [
    *Condition-specific RQA-behaviour correlations*. Each tile shows a Pearson correlation across participants between one RQA metric and one behavioural outcome for the same condition family and melody length. Behavioural values are participant-level mean correctness or mean RT for that condition, with no-response trials excluded from mean RT; RQA values are participant-level RQA summaries for the corresponding analysis window. Tile color indicates direction and magnitude, from #color-box(CORRECT) negative to #color-box(INCORRECT) positive correlations; #color-box(NO_RESPONSE) neutral tiles indicate non-significant correlations. Asterisks mark significant two-sided Pearson correlation tests, FDR-corrected across the eight RQA metrics.
  ],
)<fig:rqa-condition-correlations-1>
]

#pagebreak()
#portrait-figure[
#figure(
  {
    draw-page(second-page-metrics)
    v(CAPTION_GAP)
  },
  caption: [
    *Condition-specific RQA-behaviour correlations, continued*. Same layout as @fig:rqa-condition-correlations-1.
  ],
)<fig:rqa-condition-correlations-2>
]
