#import "@preview/cetz:0.5.2"
#import "design.typ": CAPTION_GAP, CORRECT, INCORRECT, NO_RESPONSE, color-box, portrait-figure
#import "rqa_common.typ": HEATMAP_PADDING, draw-rqa-heatmap, rqa-heatmap-height

#let length-correlation-rows = csv("../output/5_rqa_correlations/by_length.csv", row-type: dictionary)
#let condition-correlation-rows = csv("../output/5_rqa_correlations/by_condition.csv", row-type: dictionary)
#let metric-keys = ("RR", "L", "DET", "ENTR", "TT", "LAM", "V_max", "DIV")

#let correlation-row(rows, group-field, group-value, metric, outcome) = {
  let matches = rows.filter(row => (
    int(row.at(group-field)) == group-value
    and row.metric == metric
    and row.outcome == outcome
  ))
  if matches.len() != 1 {
    panic("Expected one correlation row for " + group-field + "=" + str(group-value) + ", metric=" + metric + ", outcome=" + outcome)
  }
  matches.first()
}

#let correlation-values(rows, group-field, group-values, outcome) = group-values.map(group-value => (
  metric-keys.map(metric => float(correlation-row(rows, group-field, group-value, metric, outcome).r))
))

#let correlation-significance(rows, group-field, group-values, outcome) = group-values.map(group-value => (
  metric-keys.map(metric => float(correlation-row(rows, group-field, group-value, metric, outcome).p_value_fdr_8way) < 0.05)
))

#portrait-figure[
#figure(
  {
    let columns = ([RR], [L], [DET], [ENTR], [TT], [LAM], [$V_"max"$], [DIV])
    let length-rows = ([M3], [M5], [M7])
    let condition-rows = ([Memorized#h(-0.5em)], [Early change#h(-0.5em)], [Late change#h(-0.5em)])
    let HEATMAP_HEIGHT = rqa-heatmap-height(length-rows)

    let length-values = (3, 5, 7)
    let condition-values = (1, 2, 3)
    let length-accuracy = correlation-values(length-correlation-rows, "melody_length", length-values, "accuracy")
    let length-accuracy-significant = correlation-significance(length-correlation-rows, "melody_length", length-values, "accuracy")
    let length-rt = correlation-values(length-correlation-rows, "melody_length", length-values, "mean_rt")
    let length-rt-significant = correlation-significance(length-correlation-rows, "melody_length", length-values, "mean_rt")
    let condition-accuracy = correlation-values(condition-correlation-rows, "condition_index", condition-values, "accuracy")
    let condition-accuracy-significant = correlation-significance(condition-correlation-rows, "condition_index", condition-values, "accuracy")
    let condition-rt = correlation-values(condition-correlation-rows, "condition_index", condition-values, "mean_rt")
    let condition-rt-significant = correlation-significance(condition-correlation-rows, "condition_index", condition-values, "mean_rt")

    align(center, cetz.canvas({
      let y4 = 0em
      let y3 = y4 + HEATMAP_HEIGHT + HEATMAP_PADDING
      let y2 = y3 + HEATMAP_HEIGHT + HEATMAP_PADDING
      let y1 = y2 + HEATMAP_HEIGHT + HEATMAP_PADDING

      draw-rqa-heatmap((0em, y1), [Melody length and accuracy], length-rows, columns, length-accuracy, length-accuracy-significant, circle-row-labels: true, show-column-labels: false)
      draw-rqa-heatmap((0em, y2), [Melody length and mean RT], length-rows, columns, length-rt, length-rt-significant, circle-row-labels: true, show-column-labels: false)
      draw-rqa-heatmap((0em, y3), [Condition and accuracy], condition-rows, columns, condition-accuracy, condition-accuracy-significant, show-column-labels: false)
      draw-rqa-heatmap((0em, y4), [Condition and mean RT], condition-rows, columns, condition-rt, condition-rt-significant)
    }))
    v(CAPTION_GAP)
  },
  caption: [
    *RQA-behaviour correlations across melody length and condition*. Melody-length correlations were calculated after averaging each participant across conditions, whereas condition correlations were calculated after averaging across melody lengths. Heatmaps show Pearson correlations between RQA metrics and behavioural accuracy or mean response time across participants; no-response trials were excluded from mean response times. Tile values are Pearson correlation coefficients. Tile color indicates direction and magnitude, from #color-box(CORRECT) negative to #color-box(INCORRECT) positive correlations; #color-box(NO_RESPONSE) neutral tiles indicate non-significant correlations. Asterisks mark significant two-sided Pearson correlation tests, FDR-corrected across the eight RQA metrics.
  ],
)<fig:rqa-behaviour-correlations>
]
