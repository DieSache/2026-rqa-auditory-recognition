#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": AXIS_TEXT_SIZE, CAPTION_GAP, EARLY_CHANGE, LATE_CHANGE, MEMORIZED, RQA_METRICS, RQA_PANEL_GAP, color-box, portrait-figure
#import "rqa_common.typ": distribution-panel

#let source-rows = csv("../output/rqa_metric_distributions_plot_data.csv", row-type: dictionary)
#let rows = source-rows.map(row => row + (plot_group_index: row.condition_index))
#let groups = (
  (index: 1, label: [Memorized], color: MEMORIZED),
  (index: 2, label: [Early change], color: EARLY_CHANGE),
  (index: 3, label: [Late change], color: LATE_CHANGE),
)
#let tick-values = groups.map(group => group.index)
#let ticks = groups.map(group => (
  group.index,
  {
    v(0.5em)
    rotate(-20deg, text(size: AXIS_TEXT_SIZE, group.label))
  }
))

#let panels = RQA_METRICS.enumerate().map(((index, metric)) => distribution-panel(
  rows,
  metric,
  groups,
  panel-size: 14em,
  ticks: if index >= RQA_METRICS.len() - 2 { ticks } else { tick-values },
  show-x-tick-labels: index >= RQA_METRICS.len() - 2,
))

#portrait-figure[
  #figure(
    {
      align(center, {
        show: lq.layout
        grid(columns: 2, column-gutter: RQA_PANEL_GAP, row-gutter: RQA_PANEL_GAP, ..panels)
      })
      v(CAPTION_GAP)
    },
    caption: [
      *RQA metric distributions by condition family*. Scatter and box plots show participant-level RQA metric distributions for #color-box(MEMORIZED) memorized (M), #color-box(EARLY_CHANGE) early-change, and #color-box(LATE_CHANGE) late-change melodies. Melody lengths are pooled within each condition family.
    ],
  )<fig:rqa-condition-distributions>
]
