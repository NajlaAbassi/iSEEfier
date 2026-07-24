# iSEEinit: Create an initial state of an iSEE instance for gene expression visualization

`iSEEinit()` defines the initial setup of an iSEE instance, recommending
tailored visual elements to effortlessly illustrate the expression of a
gene list in a single view.

## Usage

``` r
iSEEinit(
  sce,
  features,
  reddim_type = "TSNE",
  clusters = colnames(colData(sce))[1],
  groups = colnames(colData(sce))[1],
  gene_id = "id",
  add_markdown_panel = FALSE
)
```

## Arguments

- sce:

  SingleCellExperiment object

- features:

  A character vector or a data.frame containing a list of genes. If
  `features` is a data.frame, the column containing the gene names must
  be named "id"

- reddim_type:

  A string vector containing the dimensionality reduction type

- clusters:

  A character string containing the name of the
  clusters/cell-type/state...(as listed in the colData of the sce)

- groups:

  A character string of the groups/conditions...(as it appears in the
  colData of the sce)

- gene_id:

  A character string containing the name of the column name containing
  gene names/ids, when 'features' is a data.frame

- add_markdown_panel:

  A logical indicating whether or not to include the MarkdownBoard panel
  in the initial configuration

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
gene_list <- c("ENSMUSG00000026581",
               "ENSMUSG00000005087",
               "ENSMUSG00000015437")
cluster <- "stimulus"
group <- "single cell quality"
initial <- iSEEinit(sce = sce, features = gene_list, clusters = cluster, groups = group)
```
