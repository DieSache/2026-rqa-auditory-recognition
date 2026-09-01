#import "@preview/cetz:0.5.2"
#import "design.typ": CAPTION_GAP, CORRECT, INCORRECT, color-box, landscape-figure
#import "behaviour_common.typ": BAR_HEIGHT, BAR_WIDTH, CONDITIONS, RESPONSE_CATEGORIES, SIGNIFICANCE_ROW_GAP, SIGNIFICANCE_Y, condition-x, draw-baseline, draw-condition-tick-label, draw-melody-group-label, draw-significance-bar, group-index-x

#landscape-figure[
#figure(
  {
    let rt-rows = csv("../output/statistics/behaviour_subject.csv", row-type: dictionary)
    let test-rows = csv("../output/statistics/behaviour_comparisons.csv", row-type: dictionary)
    let RESPONSE_BAR_WIDTH = BAR_WIDTH / 2
    let condition-indices = (old: "1", early: "2", late: "3")
    let melody-codes = (M3: "3", M5: "5", M7: "7")
    let response-columns = (right: "correct_rt", wrong: "incorrect_rt")

    let valid-rt(value) = {
      value != "NaN"
    }

    let rt-values(group-key, condition-key, response-key) = {
      rt-rows
        .filter(row => row.melody_length == melody-codes.at(group-key) and row.condition_index == condition-indices.at(condition-key) and valid-rt(row.at(response-columns.at(response-key))))
        .map(row => float(row.at(response-columns.at(response-key))))
    }

    let mean(values) = {
      values.sum() / values.len()
    }

    let all-rt-values = ()
    for row in rt-rows {
      for response-key in ("right", "wrong") {
        let value = row.at(response-columns.at(response-key))
        if valid-rt(value) {
          all-rt-values.push(float(value))
        }
      }
    }

    let RT_MAX = calc.max(..all-rt-values)
    let RT_TICK_STEP = 500
    let RT_AXIS_MAX = calc.ceil(RT_MAX / RT_TICK_STEP) * RT_TICK_STEP
    let RT_TICKS = range(0, int(RT_AXIS_MAX) + 1, step: RT_TICK_STEP)

    let rt-data = () => (
      (
        key: "M3",
        label: [M3],
        old: (mean(rt-values("M3", "old", "right")), mean(rt-values("M3", "old", "wrong"))),
        early: (mean(rt-values("M3", "early", "right")), mean(rt-values("M3", "early", "wrong"))),
        late: (mean(rt-values("M3", "late", "right")), mean(rt-values("M3", "late", "wrong"))),
      ),
      (
        key: "M5",
        label: [M5],
        old: (mean(rt-values("M5", "old", "right")), mean(rt-values("M5", "old", "wrong"))),
        early: (mean(rt-values("M5", "early", "right")), mean(rt-values("M5", "early", "wrong"))),
        late: (mean(rt-values("M5", "late", "right")), mean(rt-values("M5", "late", "wrong"))),
      ),
      (
        key: "M7",
        label: [M7],
        old: (mean(rt-values("M7", "old", "right")), mean(rt-values("M7", "old", "wrong"))),
        early: (mean(rt-values("M7", "early", "right")), mean(rt-values("M7", "early", "wrong"))),
        late: (mean(rt-values("M7", "late", "right")), mean(rt-values("M7", "late", "wrong"))),
      ),
    )

    let condition-key = (old: "old", early_change: "early", late_change: "late")
    let response-key(value) = if value == "Right" { "right" } else { "wrong" }
    let significant-tests = test-rows.filter(row => row.significant_fdr_45way == "1")
    let rt-significance(length) = {
      let response = significant-tests
        .filter(row => row.comparison_family == "right_vs_wrong_within_cell" and int(row.melody_length_a) == length)
        .map(row => (condition: condition-key.at(row.condition_a_family), level: text(row.significance_fdr_45way)))
      let condition = significant-tests
        .filter(row => row.comparison_family == "condition_within_melody_and_response" and int(row.melody_length_a) == length)
        .map(row => (
          response: response-key(row.response_a),
          at: (condition-key.at(row.condition_a_family), condition-key.at(row.condition_b_family)),
          level: text(row.significance_fdr_45way),
        ))
      (response: response, condition: condition)
    }
    let rt-planned-significance = () => (
      within: (M3: rt-significance(3), M5: rt-significance(5), M7: rt-significance(7)),
    )

    let data = rt-data()
    let significance = rt-planned-significance()
    let response-categories = RESPONSE_CATEGORIES.slice(0, 2)
    let response-indices = (right: 0, wrong: 1)
    let count-rt-significance = significance => {
      let total = 0

      if "response" in significance {
        total += significance.response.len()
      }
      if "condition" in significance {
        total += significance.condition.len()
      }

      total
    }
    let max-rt-significance = calc.max(..data.map(group => count-rt-significance(significance.within.at(group.key))))
    let group-label-y = SIGNIFICANCE_Y + max-rt-significance * SIGNIFICANCE_ROW_GAP + 1.1em

    let response-center-x(group-x, condition-key, response-key) = {
      condition-x(group-x, condition-key) + response-indices.at(response-key) * RESPONSE_BAR_WIDTH + RESPONSE_BAR_WIDTH / 2
    }

    align(center, cetz.canvas({
      import cetz.draw: *

      draw-baseline(data.len())
      line((0, 0), (0, BAR_HEIGHT))
      for value in RT_TICKS {
        let y = BAR_HEIGHT * value / RT_AXIS_MAX
        line((0, y), (-0.35em, y))
        content((-0.55em, y), anchor: "east", text(size: 8pt)[#value])
      }
      content(
        (-3.2em, BAR_HEIGHT / 2),
        angle: 90deg,
        anchor: "south",
        [Reaction time (ms)],
      )

      let bar-height(value) = {
        BAR_HEIGHT * value / RT_AXIS_MAX
      }

      let quantile(values, probability) = {
        let sorted = values.sorted()
        let position = (sorted.len() - 1) * probability
        let lower = calc.floor(position)
        let upper = calc.ceil(position)
        let fraction = position - lower
        sorted.at(lower) * (1 - fraction) + sorted.at(upper) * fraction
      }

      let draw-response-bars(x, values, prefix) = {
        for (index, (value, category)) in values.zip(response-categories).enumerate() {
          let bar-x = x + index * RESPONSE_BAR_WIDTH
          let top = bar-height(value)
          let bar-name = prefix + "-" + str(index)
          rect((bar-x, 0), (bar-x + RESPONSE_BAR_WIDTH, top), name: bar-name, fill: category.color)
          content(
            bar-name + ".center",
            angle: 90deg,
            text(fill: white, size: 10pt)[#str(calc.round(value)) ms],
          )
        }
      }

      let point-jitter(point-index, condition-index, response-index) = {
        (calc.rem(point-index * 37 + condition-index * 19 + response-index * 11, 100) / 100 - 0.5) * RESPONSE_BAR_WIDTH * 0.55
      }

      let draw-response-points(group-x, group-key, condition-key, condition-index, response-key) = {
        let response-index = response-indices.at(response-key)
        let center-x = response-center-x(group-x, condition-key, response-key)
        for (point-index, value) in rt-values(group-key, condition-key, response-key).enumerate() {
          circle(
            (center-x + point-jitter(point-index, condition-index, response-index), bar-height(value)),
            radius: 0.1em,
            fill: black.transparentize(45%),
            stroke: none,
          )
        }
      }

      let draw-response-boxplot(group-x, group-key, condition-key, response-key) = {
        let values = rt-values(group-key, condition-key, response-key)
        let q1 = quantile(values, 0.25)
        let median = quantile(values, 0.5)
        let q3 = quantile(values, 0.75)
        let iqr = q3 - q1
        let lower-values = values.filter(value => value >= q1 - 1.5 * iqr)
        let upper-values = values.filter(value => value <= q3 + 1.5 * iqr)
        let lower-whisker = calc.min(..lower-values)
        let upper-whisker = calc.max(..upper-values)
        let center-x = response-center-x(group-x, condition-key, response-key)
        let half-width = RESPONSE_BAR_WIDTH * 0.3
        let cap-width = RESPONSE_BAR_WIDTH * 0.18

        line((center-x, bar-height(lower-whisker)), (center-x, bar-height(q1)), stroke: black + 0.8pt)
        line((center-x, bar-height(q3)), (center-x, bar-height(upper-whisker)), stroke: black + 0.8pt)
        line((center-x - cap-width, bar-height(lower-whisker)), (center-x + cap-width, bar-height(lower-whisker)), stroke: black + 0.8pt)
        line((center-x - cap-width, bar-height(upper-whisker)), (center-x + cap-width, bar-height(upper-whisker)), stroke: black + 0.8pt)
        rect(
          (center-x - half-width, bar-height(q1)),
          (center-x + half-width, bar-height(q3)),
          fill: white.transparentize(25%),
          stroke: black + 0.8pt,
        )
        line((center-x - half-width, bar-height(median)), (center-x + half-width, bar-height(median)), stroke: black + 1.2pt)
      }

      let draw-within-significance(group-x, group-key) = {
        if group-key in significance.within {
          let group-significance = significance.within.at(group-key)
          let row = 0

          if "response" in group-significance {
            for entry in group-significance.response {
              let xs = ("right", "wrong").map(response => response-center-x(group-x, entry.condition, response))
              let y = SIGNIFICANCE_Y + row * SIGNIFICANCE_ROW_GAP

              draw-significance-bar(xs, y, entry.level)
              row += 1
            }
          }

          if "condition" in group-significance {
            for entry in group-significance.condition {
              let xs = entry.at.map(condition => response-center-x(group-x, condition, entry.response))
              let y = SIGNIFICANCE_Y + row * SIGNIFICANCE_ROW_GAP

              let color = if entry.response == "right" { CORRECT } else { INCORRECT }
              draw-significance-bar(xs, y, entry.level, color: color)
              row += 1
            }
          }
        }
      }

      for (group-index, group) in data.enumerate() {
        let group-x = group-index-x(group-index)
        draw-melody-group-label(group-x, group-label-y, group.label)

        for (condition-index, condition) in CONDITIONS.enumerate() {
          let condition-start-x = condition-x(group-x, condition.key)
          draw-response-bars(condition-start-x, group.at(condition.key), "rt-bar-" + str(group-index) + "-" + str(condition-index))
          draw-response-boxplot(group-x, group.key, condition.key, "right")
          draw-response-boxplot(group-x, group.key, condition.key, "wrong")
          draw-response-points(group-x, group.key, condition.key, condition-index, "right")
          draw-response-points(group-x, group.key, condition.key, condition-index, "wrong")
          draw-condition-tick-label(condition-start-x, condition.label)
        }

        draw-within-significance(group-x, group.key)
      }
    }))
    v(CAPTION_GAP)
  },
  caption: [
    *Reaction times across melody length and condition*. Bars show mean reaction time in milliseconds for #color-box(CORRECT) correct responses and #color-box(INCORRECT) incorrect responses across memorized (M), early-change, and late-change trials in the M3, M5, and M7 melody-length conditions. Points show individual subject-level mean reaction times, and boxplots show medians, interquartile ranges, and 1.5-IQR whiskers. Black brackets compare correct with incorrect responses; brackets comparing conditions within one response category use that category's color. Asterisks denote significance levels: $*p < .05$, $**p < .01$, $***p < .001$.
  ],
)<fig:behaviour-reaction-times>
]
