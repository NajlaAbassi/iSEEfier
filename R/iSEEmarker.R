#' iSEEmarker
#'
#' `iSEEmarker()` creates an initial state of an iSEE instance for interactive
#' exploration of marker genes through the `DynamicMarkerTable` panel, synchronizing
#' selections with a `ReducedDimensionPlot` and a `FeatureAssayPlot` to visualize
#' the expression of selected marker genes
#'
#' @param sce SingleCellExperiment object
#' @param reddim_type A string vector containing the dimensionality reduction
#' @param clusters A character string containing the name of the
#'   clusters/cell-type/state...(as listed in the colData of the sce)
#' @param groups A character string of the groups/conditions...(as it appears in
#'   the colData of the sce)
#' @param selection_plot_format A string character containing the class of the panel.
#'  It can be either `ColumnDataPlot` or `ReducedDimensionPlot`
#'
#' @return A list of "Panel" objects specifying the initial state of iSEE
#'   instance
#' @export
#' @importFrom methods new
#' @importFrom SummarizedExperiment colData
#' @importFrom SingleCellExperiment reducedDimNames
#' @importFrom methods is
#' @importClassesFrom iSEE ColumnDataPlot
#' @importClassesFrom iSEE ReducedDimensionPlot
#' @importClassesFrom iSEE FeatureAssayPlot
#' @importFrom BiocBaseUtils isCharacter isScalarCharacter isTRUEorFALSE
#' @examples
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' sce <- scater::runTSNE(sce)
#' cluster <- "stimulus"
#' group <- "single cell quality"
#' initial <- iSEEmarker(sce = sce, clusters = cluster, groups = group,
#' selection_plot_format = "ColumnDataPlot")
#'
#'
iSEEmarker <- function(sce,
                       reddim_type = "TSNE",
                       clusters = colnames(colData(sce))[1],
                       groups = colnames(colData(sce))[1],
                       selection_plot_format = c("ColumnDataPlot",
                                                 "ReducedDimensionPlot")) {
  ## Checks on arguments
  selection_plot_format <- match.arg(selection_plot_format,
                                     c("ColumnDataPlot", "ReducedDimensionPlot"))
  
  
  if (!is(sce, "SingleCellExperiment"))
    stop("Please provide a SingleCellExperiment as input!")
  
  stopifnot(isScalarCharacter(reddim_type))
  
  stopifnot(isScalarCharacter(clusters))
  
  stopifnot(isScalarCharacter(groups))
  
  stopifnot(isScalarCharacter(selection_plot_format))
  
  if (!(reddim_type %in% reducedDimNames(sce))) {
    available_reddims <- reducedDimNames(sce)
    stop(
      "The selected reduced dimensionality embedding is not available!\n",
      "Please select one of these: ",
      paste(available_reddims, collapse = ", ")
    )
  }
  
  if (!(clusters %in% colnames(colData(sce)))) {
    if (ncol(colData(sce)) > 0) {
      fallback_clusters <- colnames(colData(sce))[1]
    } else {
      stop("No colData provided for the `clusters`!")
    }
    
    message(
      "colData column not found for the `clusters` parameter, defaulting to ",
      fallback_clusters
    )
  }
  
  if (!(groups %in% colnames(colData(sce)))) {
    if (ncol(colData(sce)) > 0) {
      fallback_groups <- colnames(colData(sce))[1]
    } else {
      stop("No colData provided for the `groups`!")
    }
    
    message(
      "colData column not found for the `groups` parameter, defaulting to ",
      fallback_groups
    )
  }
  
  
  
  initial <- list()
  
  plots <- list(
    ReducedDimensionPlot = list(
      plot_name = "ReducedDimensionPlot2",
      plot_type = "ReducedDimensionPlot",
      plot_args = list(
        Type = reddim_type,
        ColorBy = "Column data",
        ColorByColumnData = clusters,
        PanelWidth = 6L
      ),
      marker_table_suffix = "2"
    ),
    
    ColumnDataPlot = list(
      plot_name = "ColumnDataPlot1",
      plot_type = "ColumnDataPlot",
      plot_args = list(
        YAxis = clusters,
        ColorBy = "Column data",
        ColorByColumnData = clusters,
        PanelWidth = 6L
      ),
      marker_table_suffix = "1"
    )
  )
  
  config <- plots[[selection_plot_format]]
  
  initial[["DynamicMarkerTable1"]] <- new(
    "DynamicMarkerTable",
    ColumnSelectionSource = paste0(selection_plot_format, config$marker_table_suffix)
  )
  
  initial[["ReducedDimensionPlot1"]] <- new(
    "ReducedDimensionPlot",
    Type = reddim_type,
    FacetColumnByColData = groups,
    FacetColumnBy = "Column data",
    ColorBy = "Feature name",
    ColorByFeatureSource = "DynamicMarkerTable1",
    SelectionAlpha = 0.05
  )
  
  initial[["FeatureAssayPlot1"]] <- new(
    "FeatureAssayPlot",
    XAxis = "Column data",
    XAxisColumnData = groups,
    YAxisFeatureSource = "DynamicMarkerTable1"
  )
  
  initial[[config$plot_name]] <- do.call(new, c(config$plot_type, config$plot_args))
  
  return(initial)
}