# View an initial object as a network

Translates the layout of the `initial` configuration object as a
networks, representing panels as nodes and links between them as edges.

## Usage

``` r
view_initial_network(initial, plot_format = c("igraph", "visNetwork", "none"))
```

## Arguments

- initial:

  An `initial` list object, in the format that is required to be passed
  as a parameter in the call to
  [`iSEE::iSEE()`](https://isee.github.io/iSEE/reference/iSEE.html).

- plot_format:

  Character string, one of `igraph`, `visNetwork`, or `none`. Defaults
  to `igraph`. Determines the format of the visual representation
  generated as a side effect of this function - it can be the output of
  the [`plot()`](https://rdrr.io/r/graphics/plot.default.html) function
  for `igraph` objects, or an interactive widget created via
  [`visNetwork::visNetwork()`](https://rdrr.io/pkg/visNetwork/man/visNetwork.html).

## Value

An `igraph` object, underlying the visual representation provided.

## Details

Panels are the nodes, with color and names to identify them easily. The
connections among panels are represented through directed edges. This
can be a compact visualization to obtain an overview for the
configuration, without the need of fully launching the app and loading
the content of all panels

This function is particularly useful with mid-to-large `initial`
objects, as they can be quickly generated in a programmatic manner via
the [`iSEEinit()`](iSEEinit.md) provided in this package.

## See also

[`view_initial_tiles()`](view_initial_tiles.md)

## Examples

``` r
## Load a dataset and preprocess this quickly
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
## Select some features and aspects to focus on
gene_list <- c("ENSMUSG00000026581", "ENSMUSG00000005087", "ENSMUSG00000015437")
cluster <- "stimulus"
group <- "single cell quality"
initial <- iSEEinit(sce = sce,
                    features = gene_list,
                    clusters = cluster,
                    groups = group)

g_init <- view_initial_network(initial)

g_init
#> IGRAPH 85adfa7 DN-- 13 4 -- 
#> + attr: name (v/c), color (v/c)
#> + edges from 85adfa7 (vertex names):
#> [1] ReducedDimensionPlot1->ColumnDataPlot1  
#> [2] ReducedDimensionPlot2->ColumnDataPlot1  
#> [3] ReducedDimensionPlot3->ColumnDataPlot1  
#> [4] ReducedDimensionPlot4->FeatureAssayPlot4

view_initial_network(initial, plot_format = "visNetwork")
#> IGRAPH 646a90d DN-- 13 4 -- 
#> + attr: name (v/c), color (v/c)
#> + edges from 646a90d (vertex names):
#> [1] ReducedDimensionPlot1->ColumnDataPlot1  
#> [2] ReducedDimensionPlot2->ColumnDataPlot1  
#> [3] ReducedDimensionPlot3->ColumnDataPlot1  
#> [4] ReducedDimensionPlot4->FeatureAssayPlot4

## Continue your exploration directly within iSEE!
if (interactive())
  iSEE(sce, initial = initial)
#> Error in iSEE(sce, initial = initial): could not find function "iSEE"
```
