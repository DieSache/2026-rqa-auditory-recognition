#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": CAPTION_GAP, EARLY_CHANGE, LATE_CHANGE, MELODY_BADGE_DIAMETER, MEMORIZED, RQA_METRICS, RQA_PANEL_GAP, color-box, melody-badge, portrait-figure
#import "rqa_common.typ": DISTRIBUTION_TICK_TEXT_SIZE, distribution-panel

#let rows = csv("../output/rqa_metric_distributions_plot_data.csv", row-type: dictionary)
#let grouped-label(label, melody: none) = align(center)[
  #text(size: DISTRIBUTION_TICK_TEXT_SIZE, label)
  #v(-0.4em)
  #if melody == none { box(height: MELODY_BADGE_DIAMETER) } else { melody-badge(melody) }
]
#let labels = (
  grouped-label([M]), grouped-label([N2], melody: [M3]), grouped-label([N3]),
  grouped-label([M]), grouped-label([N3], melody: [M5]), grouped-label([N5]),
  grouped-label([M]), grouped-label([N5], melody: [M7]), grouped-label([N7]),
)
#let groups = range(1, 10).map(index => (
  index: index,
  color: (MEMORIZED, EARLY_CHANGE, LATE_CHANGE).at(calc.rem(index - 1, 3)),
))
#let ticks = range(1, 10).zip(labels)

#let panels = RQA_METRICS.enumerate().map(((index, metric)) => distribution-panel(
  rows,
  metric,
  groups,
  panel-size: 14em,
  ticks: if index >= RQA_METRICS.len() - 2 { ticks } else { range(1, 10) },
  show-x-tick-labels: index >= RQA_METRICS.len() - 2,
  ylabel: none,
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
      *RQA metric distributions*. Scatter and box plots show participant-level distributions for each RQA metric across the nine melody-length by condition-family combinations. Point color indicates condition family: #color-box(MEMORIZED) memorized (M), #color-box(EARLY_CHANGE) early change, and #color-box(LATE_CHANGE) late change. N labels identify the position of the changed tone.
    ],
  )<fig:rqa-condition-length-distributions>
]
