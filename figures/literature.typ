#let literature-map = csv("../input/literature/literature_direct_behaviour_map.csv", row-type: dictionary)
#let literature-summary = csv("../input/literature/literature_screen_summary.csv", row-type: dictionary)
#let literature-total = literature-map.len()
#let literature-count(method) = literature-map.filter(row => row.method == method).len()
#let literature-value(key) = int(literature-summary.find(row => row.key == key).value)
#let magnitude-count = literature-count("Evoked-response magnitude/timing") + literature-count("Oscillatory magnitude")
#let literature-share(count) = calc.round(100 * count / literature-total)

#let literature-study(row) = row.study.split("; PMID ").at(0)
#let literature-pmid(row) = row.study.split("; PMID ").at(1)

#let literature-evidence-cells(rows) = rows.map(row => (
  table.cell()[#literature-study(row)],
  table.cell()[#literature-pmid(row)],
  table.cell()[#row.domain],
  table.cell()[#row.method],
  table.cell()[#row.behavioural_link],
)).flatten()

#let literature-section(title) = table.cell(colspan: 5, fill: luma(94%), inset: (x: 2.5pt, y: 3pt))[*#title*]

#let literature-summary-table() = figure(
  kind: "supplementary-table",
  supplement: [Table S],
  numbering: "1",
  caption: [*Methodological distribution of studies directly relating neural measurements to task performance.* Percentages use all #literature-total retained studies as the denominator.],
  text(size: 7.5pt)[
    #set par(justify: false)
    #table(
      columns: (2.2fr, 0.7fr, 0.7fr),
      align: (left, center, center),
      inset: (x: 4pt, y: 3pt),
      stroke: (x: none, y: 0.35pt + luma(78%)),
      table.header([*Neural measure related to behaviour*], [*Studies*], [*Share*]),
      [Evoked-response magnitude or timing], [#literature-count("Evoked-response magnitude/timing")], [#literature-share(literature-count("Evoked-response magnitude/timing"))%],
      [Oscillatory magnitude], [#literature-count("Oscillatory magnitude")], [#literature-share(literature-count("Oscillatory magnitude"))%],
      [Neural coordination], [#literature-count("Neural coordination")], [#literature-share(literature-count("Neural coordination"))%],
      [Multivariate representation or prediction], [#literature-count("Multivariate representation/prediction")], [#literature-share(literature-count("Multivariate representation/prediction"))%],
      [Temporal-state dynamics], [#literature-count("Temporal-state dynamics")], [#literature-share(literature-count("Temporal-state dynamics"))%],
    )
  ],
)

#let search-query(title, path) = [
  *#title*
  #block(width: 100%, breakable: false, fill: luma(96%), inset: 7pt, radius: 2pt)[
    #set text(size: 6.8pt)
    #raw(read(path), block: true)
  ]
]

#let literature-evidence-table() = [
  #{
    set text(size: 8pt, hyphenate: false)
    set par(justify: false)
    table(
      columns: (auto, auto, auto, auto, auto),
      align: (left, left, left, left, left),
      inset: (x: 2.5pt, y: 2.5pt),
      stroke: (x: none, y: 0.35pt + luma(80%)),
      table.header([*Study*], [*PMID*], [*Task domain*], [*Neural measure*], [*Behavioural measure*]),
      literature-section([Recent auditory and musical studies (2020--2026)]),
      ..literature-evidence-cells(literature-map.slice(0, 26)),
      table.hline(stroke: 0.55pt + luma(55%)),
      literature-section([Earlier auditory and musical studies (2015--2019)]),
      ..literature-evidence-cells(literature-map.slice(26, 45)),
      table.hline(stroke: 0.55pt + luma(55%)),
      literature-section([Other temporally unfolding tasks]),
      ..literature-evidence-cells(literature-map.slice(45)),
    )
  }
  #figure(
    kind: "supplementary-table",
    supplement: [Table S],
    numbering: "1",
    caption: [*Direct neural--behaviour evidence map.* PMID, PubMed identifier.],
    box(width: 100%, height: 0pt),
  )<tab:literature-evidence-map>
]

#let literature-supplement() = [
  === Neural--behaviour literature screen

  We conducted two complementary, method-neutral PubMed searches for human electrophysiological studies that related neural measurements directly to memory, recognition, or learning behaviour. Both searches were performed on 6 August 2026 and restricted to records published from 2015 onward. The auditory search returned #literature-value("auditory_records") records. The complementary search for sequential, continuous, or otherwise temporally unfolding stimuli returned #literature-value("temporal_records") records. #literature-value("duplicate_records") records occurred in both searches, yielding #literature-value("unique_records") unique records for title-and-abstract screening.

  A study was retained only when it explicitly tested a statistical relationship between a neural measure and observed behavioural performance. Eligible relationships included comparisons between correct and incorrect or subsequently remembered and forgotten trials, participant-level neural--behaviour correlations, and models predicting accuracy, response time, recall, discrimination, or learning; explicit null tests were retained. We excluded studies that reported neural and behavioural condition effects without testing their relationship, decoded content without relating the neural measure to performance, or related neural activity only to an external cognitive, clinical, or demographic measure. Non-human studies and studies without a relevant behavioural outcome were also excluded. Retained measures were classified as evoked-response magnitude or timing, oscillatory magnitude, neural coordination, multivariate representation or prediction, or temporal-state dynamics. Neural coordination comprised phase, entrainment, connectivity, synchronization, and cross-frequency coupling; multivariate methods comprised decoding, representational similarity, and predictive models using distributed neural features. For studies with several analyses, classification followed the measure tested against behaviour.

  #literature-total studies met the direct neural--behaviour criterion: #literature-value("auditory_or_musical_studies") used auditory or musical tasks and #literature-value("other_temporal_studies") used other temporally unfolding tasks. Evoked-response magnitude or timing was used in #literature-count("Evoked-response magnitude/timing") studies and oscillatory magnitude in #literature-count("Oscillatory magnitude") studies. Together, these accounted for #magnitude-count of #literature-total retained studies (#literature-share(magnitude-count)%). #literature-count("Neural coordination") studies used neural-coordination measures, #literature-count("Multivariate representation/prediction") used multivariate representations or prediction, and #literature-count("Temporal-state dynamics") used temporal-state dynamics. No retained study used a standalone entropy or information-complexity measure as its primary behavioural neural variable. These findings characterize the retained PubMed sample and are not intended as an exhaustive systematic review.

  #literature-summary-table()<tab:literature-method-summary>

  #pagebreak()
  #search-query([Exact auditory query.], "../input/literature/literature_search_query.txt")

  #pagebreak()
  #search-query([Exact temporal-stimulus query.], "../input/literature/literature_search_query_temporal.txt")

  #pagebreak()
  #literature-evidence-table()
]
