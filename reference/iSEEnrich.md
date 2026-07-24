# iSEEnrich

`iSEEnrich()` creates an initial state of an iSEE instance for
interactive exploration of feature sets extracted from GO and KEGG
database, displaying all associated genes in a `RowDataTable` panel.

## Usage

``` r
iSEEnrich(
  sce,
  collection = c("GO", "KEGG"),
  organism = "org.Hs.eg.db",
  gene_identifier = "ENTREZID",
  clusters = colnames(colData(sce))[1],
  groups = colnames(colData(sce))[1],
  reddim_type = "PCA"
)
```

## Arguments

- sce:

  SingleCellExperiment object

- collection:

  A character vector specifying the gene set collections of interest
  (GO,KEGG)

- organism:

  A character string of the org.\*.eg.db package to use to extract
  mappings of gene sets to gene IDs.

- gene_identifier:

  A character string specifying the identifier to use to extract gene
  IDs for the organism package

- clusters:

  A character string containing the name of the
  clusters/cell-type/state...(as listed in the colData of the sce)

- groups:

  A character string of the groups/conditions...(as it appears in the
  colData of the sce)

- reddim_type:

  A string vector containing the dimensionality reduction type

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
GO_collection <- "GO"
Mm_organism <- "org.Mm.eg.db"
gene_id <- "SYMBOL"
clusters <- "stimulus"
groups <- "single cell quality"
reddim_type <- "PCA"
results <- iSEEnrich(sce = sce,
                     collection = GO_collection,
                     organism = Mm_organism,
                     gene_identifier = gene_id,
                     clusters = clusters,
                     groups = groups,
                     reddim_type = reddim_type)
#> 
```
