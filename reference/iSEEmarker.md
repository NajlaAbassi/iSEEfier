# iSEEmarker

`iSEEmarker()` creates an initial state of an iSEE instance for
interactive exploration of marker genes through the `DynamicMarkerTable`
panel, synchronizing selections with a `ReducedDimensionPlot` and a
`FeatureAssayPlot` to visualize the expression of selected marker genes

## Usage

``` r
iSEEmarker(
  sce,
  reddim_type = "TSNE",
  clusters = colnames(colData(sce))[1],
  groups = colnames(colData(sce))[1],
  selection_plot_format = c("ColumnDataPlot", "ReducedDimensionPlot")
)
```

## Arguments

- sce:

  SingleCellExperiment object

- reddim_type:

  A string vector containing the dimensionality reduction

- clusters:

  A character string containing the name of the
  clusters/cell-type/state...(as listed in the colData of the sce)

- groups:

  A character string of the groups/conditions...(as it appears in the
  colData of the sce)

- selection_plot_format:

  A string character containing the class of the panel. It can be either
  `ColumnDataPlot` or `ReducedDimensionPlot`

## Value

A list of "Panel" objects specifying the initial state of iSEE instance

## Examples

``` r
sce <- scRNAseq::RichardTCellData()
#> snapshotDate(): 2026-07-24
#> Error while performing HEAD request.
#>    Proceeding without cache information.
#> loading from cache
#> Error while performing HEAD request.
#>    Proceeding without cache information.
sce <- scuttle::logNormCounts(sce)
#> Warning: 'librarySizeFactors' is deprecated.
#> Use 'scrapper::centerSizeFactors' instead.
#> See help("Deprecated")
#> Warning: 'normalizeCounts' is deprecated.
#> Use 'scrapper::normalizeCounts' instead.
#> See help("Deprecated")
sce <- scater::runPCA(sce)
sce <- scater::runTSNE(sce)
cluster <- "stimulus"
group <- "single cell quality"
initial <- iSEEmarker(sce = sce, clusters = cluster, groups = group,
selection_plot_format = "ColumnDataPlot")

```
