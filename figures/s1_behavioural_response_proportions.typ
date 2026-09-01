#import "@preview/cetz:0.5.2"
#import "design.typ": CAPTION_GAP, CORRECT, INCORRECT, NO_RESPONSE, color-box, landscape-figure
#import "behaviour_common.typ": BAR_HEIGHT, BAR_WIDTH, CONDITIONS, RESPONSE_CATEGORIES, SIGNIFICANCE_COLORS, SIGNIFICANCE_KINDS, SIGNIFICANCE_ROW_GAP, SIGNIFICANCE_Y, condition-center-x, condition-x, count-significance, draw-baseline, draw-condition-tick-label, draw-melody-group-label, draw-significance-bar, group-index-x

#landscape-figure[
#figure(
  {
    let response-rows = csv("../output/statistics/behaviour_subject.csv", row-type: dictionary)
    let test-rows = csv("../output/statistics/behaviour_response_comparisons.csv", row-type: dictionary)
    let response-columns = ("accuracy", "incorrect", "no_response")
    let mean-column(rows, condition, column) = {
      let values = rows.filter(row => int(row.condition_index) == condition).map(row => float(row.at(column)))
      values.sum() / values.len()
    }
    let significance(length, response) = {
      test-rows
        .filter(row => row.comparison_family == "condition" and int(row.melody_length_a) == length and row.response_a == response and row.significant_fdr_family == "1")
        .map(row => (at: (row.condition_a, row.condition_b), level: text(row.display_significance)))
    }
    let group(key, length) = {
      let rows = response-rows.filter(row => int(row.melody_length) == length)
      (
        key: key,
        label: text(key),
        old: response-columns.map(response => mean-column(rows, 1, response)),
        early: response-columns.map(response => mean-column(rows, 2, response)),
        late: response-columns.map(response => mean-column(rows, 3, response)),
        significance: (right: significance(length, "correct"), wrong: significance(length, "incorrect")),
      )
    }
    let data = (group("M3", 3), group("M5", 5), group("M7", 7))

    let segment-colors = RESPONSE_CATEGORIES.map(category => category.color)
    let group-label-y = SIGNIFICANCE_Y + calc.max(..data.map(group => count-significance(group.significance))) * SIGNIFICANCE_ROW_GAP + 1.1em

    align(center, cetz.canvas({
      import cetz.draw: *

      draw-baseline(data.len())
      let draw-bar(x, values, prefix) = {
        let y = 0em
        for (segment-index, (value, fill)) in values.zip(segment-colors).enumerate() {
          let segment-name = prefix + "-" + str(segment-index)
          rect((x, y), (x + BAR_WIDTH, y + BAR_HEIGHT * value), name: segment-name, fill: fill)
          content(segment-name + ".center", text(fill: white, size: 9.5pt)[#str(calc.round(value * 100))%])
          y += BAR_HEIGHT * value
        }
      }

      let draw-within-significance(group-x, significance) = {
        let row = 0

        for kind in SIGNIFICANCE_KINDS {
          if kind in significance {
            let stroke = SIGNIFICANCE_COLORS.at(kind)

            for entry in significance.at(kind) {
              let xs = entry.at.map(condition => condition-center-x(group-x, condition))
              let y = SIGNIFICANCE_Y + row * SIGNIFICANCE_ROW_GAP

              draw-significance-bar(xs, y, entry.level, color: stroke)
              row += 1
            }
          }
        }
      }

      for (group-index, group) in data.enumerate() {
        let group-x = group-index-x(group-index)
        draw-melody-group-label(group-x, group-label-y, group.label)

        for (condition-index, condition) in CONDITIONS.enumerate() {
          let bar-x = condition-x(group-x, condition.key)
          draw-bar(bar-x, group.at(condition.key), "bar-" + str(group-index) + "-" + str(condition-index))
          draw-condition-tick-label(bar-x, condition.label)
        }

        draw-within-significance(group-x, group.significance)
      }
    }))
    v(CAPTION_GAP)
  },
  caption: [
    *Behavioural response proportions across melody length and condition*. Stacked bars show the proportion of #color-box(CORRECT) correct responses, #color-box(INCORRECT) incorrect responses, and #color-box(NO_RESPONSE) no responses across memorized (M), early-change, and late-change trials in the M3, M5, and M7 melody-length conditions. Percentages are shown within each response category. Brackets indicate significant FDR-corrected comparisons and use the color of the response category being compared. Asterisks denote significance levels: $*p < .05$, $**p < .01$, $***p < .001$.
  ],
)<fig:behaviour-response-proportions-stacked>
]
