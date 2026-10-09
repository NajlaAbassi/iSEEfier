<img src="inst/www/iSEEfier.png" align="right" alt="" width="120" />

# iSEEfier

<!-- badges: start -->
  [![R-CMD-check](https://github.com/NajlaAbassi/iSEEfier/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/NajlaAbassi/iSEEfier/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

<br>

The goal of `iSEEfier` is to provides a set of functionality to quickly and intuitively create, 
inspect, and combine initial configuration objects for the `iSEE` package. 

These can be conveniently passed in a straightforward manner to the function call 
to launch `iSEE()` with the specified configuration,  tailored to individual visualisation
objectives. 

This package currently works seamlessly with the sets of panels provided by the 
`iSEE` and `iSEEu` packages, but can be extended to accommodate the usage of any 
custom panel (e.g. from `iSEEde`, `iSEEpathways`, or any panel developed independently
by the user).

`iSEEfier` can be found on Bioconductor
(<https://www.bioconductor.org/packages/iSEEfier>).

## Installation

You can install the release version of `iSEEfier` from Bioconductor with:

``` r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")}

BiocManager::install("iSEEfier")
```

and the development version from GitHub with:

``` r
library("remotes")
remotes::install_github("NajlaAbassi/iSEEfier", 
                        dependencies = TRUE, build_vignettes = TRUE)
```

## Example

This is a basic example which shows you how to use `iSEEfier` on a demo
dataset (the one included in the `scRNAseq` package).

``` r
library(iSEEfier)
library(iSEE)

sce <- scRNAseq::RichardTCellData()
sce <- scrapper::normalizeRnaCounts.se(sce)
sce <- scater::runPCA(sce)
sce <- scater::runTSNE(sce)

gene_list <- c("ENSMUSG00000026581", "ENSMUSG00000005087", "ENSMUSG00000015437")
cluster <- "stimulus"
group <- "single cell quality"

initial <- iSEEinit(sce = sce, features = gene_list, clusters = cluster, groups = group)

iSEE(sce, initial = initial)
```

## Usage overview

You can find the rendered version of the documentation of `iSEEfier` at
the project website <https://NajlaAbassi.github.io/iSEEfier>,
created with `pkgdown`.

## Development

If you encounter a bug, have usage questions, or want to share ideas and
functionality to make this package better, feel free to file an
[issue](https://github.com/NajlaAbassi/iSEEfier/issues).

## Code of Conduct

Please note that the iSEEfier project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). 
By contributing to this project, you agree to abide by its terms.

## License

MIT

