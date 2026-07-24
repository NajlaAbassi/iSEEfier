# iSEEfier

![](inst/www/iSEEfier.png)

  

The goal of `iSEEfier` is to provides a set of functionality to quickly
and intuitively create, inspect, and combine initial configuration
objects for the `iSEE` package.

These can be conveniently passed in a straightforward manner to the
function call to launch
[`iSEE()`](https://isee.github.io/iSEE/reference/iSEE.html) with the
specified configuration, tailored to individual visualisation
objectives.

This package currently works seamlessly with the sets of panels provided
by the `iSEE` and `iSEEu` packages, but can be extended to accommodate
the usage of any custom panel (e.g. from `iSEEde`, `iSEEpathways`, or
any panel developed independently by the user).

`iSEEfier` can be found on Bioconductor
(<https://www.bioconductor.org/packages/iSEEfier>).

## Installation

You can install the development version of `iSEEfier` from GitHub with:

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
sce <- scuttle::logNormCounts(sce)
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
the project website <https://NajlaAbassi.github.io/iSEEfier>, created
with `pkgdown`.

## Development

If you encounter a bug, have usage questions, or want to share ideas and
functionality to make this package better, feel free to file an
[issue](https://github.com/NajlaAbassi/iSEEfier/issues).

## Code of Conduct

Please note that the iSEEfier project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

MIT
