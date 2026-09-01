#import "@preview/lilaq:0.6.0" as lq
#import "design.typ": CAPTION_GAP, RQA_METRICS, RQA_PANEL_GAP, melody-badge, portrait-figure
#import "rqa_common.typ": distribution-panel

#let source-rows = csv("../output/rqa_metric_distributions_plot_data.csv", row-type: dictionary)
#let length-index(length) = if length == 3 { 1 } else if length == 5 { 2 } else { 3 }
#let rows = source-rows.map(row => row + (plot_group_index: length-index(int(row.melody_length))))
#let groups = (
  (index: 1, color: black),
  (index: 2, color: black),
  (index: 3, color: black),
)
#let tick-values = (1, 2, 3)
#let badge-ticks = (
  lq.tick(1, label: melody-badge([M3]), stroke: 0pt, inset: 0pt, outset: 0pt),
  lq.tick(2, label: melody-badge([M5]), stroke: 0pt, inset: 0pt, outset: 0pt),
  lq.tick(3, label: melody-badge([M7]), stroke: 0pt, inset: 0pt, outset: 0pt),
)

#let panels = RQA_METRICS.enumerate().map(((index, metric)) => distribution-panel(
  rows,
  metric,
  groups,
  panel-size: 13em,
  ylabel: none,
  ticks: if index < 2 { () } else { tick-values },
  extra-ticks: if index < 2 { badge-ticks } else { () },
  show-x-tick-labels: false,
  x-position: if index < 2 { top } else { bottom },
  title-pad: if index < 2 { 3.2em } else { none },
  violin: true,
  scatter-by-group: false,
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
      *RQA metric distributions by melody length*. Scatter, violin, and box plots show participant-level RQA metric distributions for M3, M5, and M7 melodies. Condition families are pooled within each melody length.
    ],
  )<fig:rqa-length-distributions>
]
