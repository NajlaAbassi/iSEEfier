#' iSEEinit: Create an initial state of an iSEE instance for gene expression
#' visualization
#'
#' `iSEEinit()` defines the initial setup of an iSEE instance, recommending
#' tailored visual elements to effortlessly illustrate the expression of a gene
#' list in a single view.
#'
#' @param sce SingleCellExperiment object
#' @param features A character vector or a data.frame containing a list of genes.
#' If `features` is a data.frame, the column containing the gene names must be named "id"
#' @param reddim_type A string vector containing the dimensionality reduction
#'   type
#' @param clusters A character string containing the name of the
#'   clusters/cell-type/state...(as listed in the colData of the sce)
#' @param groups A character string of the groups/conditions...(as it appears in
#'   the colData of the sce)
#' @param gene_id A character string containing the name of the column name containing
#'  gene names/ids, when 'features' is a data.frame
#' @param add_markdown_panel A logical indicating whether or not to include the
#'   MarkdownBoard panel in the initial configuration

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
#' @importClassesFrom iSEE RowDataTable
#' @importClassesFrom iSEE ComplexHeatmapPlot
#' @importClassesFrom iSEEu MarkdownBoard
#' @importFrom BiocBaseUtils isCharacter isScalarCharacter isTRUEorFALSE
#'
#'
#' @examples
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' sce <- scater::runTSNE(sce)
#' gene_list <- c("ENSMUSG00000026581",
#'                "ENSMUSG00000005087",
#'                "ENSMUSG00000015437")
#' cluster <- "stimulus"
#' group <- "single cell quality"
#' initial <- iSEEinit(sce = sce, features = gene_list, clusters = cluster, groups = group)
iSEEinit <- function(sce,
                     features,
                     reddim_type = "TSNE",
                     clusters = colnames(colData(sce))[1],
                     groups = colnames(colData(sce))[1],
                     gene_id="id",
                     add_markdown_panel = FALSE) {

  ## Checks on arguments
  if (!is(sce, "SingleCellExperiment"))
    stop("Please provide a SingleCellExperiment as input!")

  stopifnot(isScalarCharacter(reddim_type))

  stopifnot(isScalarCharacter(clusters))

  stopifnot(isScalarCharacter(groups))

  stopifnot(isTRUEorFALSE(add_markdown_panel))
  
  stopifnot(isScalarCharacter(gene_id))


  if (!(reddim_type %in% reducedDimNames(sce))) {
    available_reddims <- reducedDimNames(sce)
    stop("The selected reduced dimensionality embedding is not available!\n",
         "Please select one of these: ",
         paste(available_reddims, collapse = ", "))
  }
  
  if (is.data.frame(features)) {
    if ((gene_id %in% colnames(features))) {
      
      features <- as.character(features[[gene_id]])
    } else {
      stop("The column name '", gene_id,"' does not exist in the 'features' data.frame!")
    }
  }
    
  else if (is.vector(features)) {
    features <- as.character(features)
  } else {
    stop("Unsupported feature type. Must be a character vector, or data.frame!")
    }
    
  stopifnot(is.character(features), NROW(features) > 0)

  if (!all(features %in% rownames(sce))) {
    not_available_features <- features[!features %in% rownames(sce)]
    message("Some of the features specified are not available in the provided sce object!\n",
            "Feature(s) not found: ",
            paste(not_available_features, collapse = ", "))

    features <- features[features %in% rownames(sce)]
    if (NROW(features) == 0)
      stop("No features available!")
  }

  if (!(clusters %in% colnames(colData(sce)))) {
    if (ncol(colData(sce)) > 0) {
      fallback_clusters <- colnames(colData(sce))[1]
    } else {
      stop("No colData provided for the `clusters`!")
    }

    message("colData column not found for the `clusters` parameter, defaulting to ",
            fallback_clusters)
  }

  if (!(groups %in% colnames(colData(sce)))) {
    if (ncol(colData(sce)) > 0) {
      fallback_groups <- colnames(colData(sce))[1]
    } else {
      stop("No colData provided for the `groups`!")
    }

    message("colData column not found for the `groups` parameter, defaulting to ",
            fallback_groups)
  }
  


  initial <- list()
  
  
  for (j in seq_len(NROW(features))) {
    feature_name <- if (is.data.frame(features)) features[j, ] else features[[j]]
    initial[[paste0("ReducedDimensionPlot", j)]] <- new(
      "ReducedDimensionPlot",
      Type = reddim_type,
      ColorBy = "Feature name",
      ColorByFeatureName = feature_name,
      ColorByFeatureSource = paste0("RowDataTable", j),
      ColumnSelectionSource = "ColumnDataPlot1",
      SelectionAlpha = 0.05
    )

    initial[[paste0("FeatureAssayPlot", j)]] <- new(
      "FeatureAssayPlot",
      XAxis = "Column data",
      XAxisColumnData = clusters,
      YAxisFeatureName = feature_name,
      YAxisFeatureSource = paste0("RowDataTable", j),
      ColorBy = "Column data",
      ColorByColumnData = clusters
    )
    
    initial[[paste0("RowDataTable", j)]] <- new(
      "RowDataTable",
      Selected = feature_name,
      Search = feature_name
    )
  }
  
  if (NROW(features) > 1) {
    feature1 <- if (is.data.frame(features)) features[1, ] else features[[1]]
    feature2 <- if (is.data.frame(features)) features[2, ] else features[[2]]
    
    initial[[paste0("FeatureAssayPlot", NROW(features) + 1)]] <- new(
      "FeatureAssayPlot",
      XAxis = "Feature name",
      XAxisFeatureName = feature1,
      YAxisFeatureName = feature2
    )
  }
  
  if (add_markdown_panel == TRUE) {
    initial[[paste0("ReducedDimensionPlot", NROW(features) + 1)]] <- new(
      "ReducedDimensionPlot",
      Type = reddim_type,
      ColorByColumnData = clusters,
      ColorBy = "Column data",
      ColumnSelectionSource = paste0("FeatureAssayPlot", NROW(features) + 1),
      FacetColumnBy = "Column data",
      FacetColumnByColData = groups,
      SelectionAlpha = 0.05
    )
    
    initial[["MarkdownBoard1"]] <- new(
      "MarkdownBoard",
      Content = "# Placeholder\n\nFill me with text!",
      PanelWidth = 4L)
  } else {
    initial[[paste0("ReducedDimensionPlot", NROW(features) + 1)]] <- new(
      "ReducedDimensionPlot",
      Type = reddim_type,
      ColorByColumnData = clusters,
      ColorBy = "Column data",
      ColumnSelectionSource = paste0("FeatureAssayPlot", NROW(features) + 1),
      FacetColumnBy = "Column data",
      FacetColumnByColData = groups,
      SelectionAlpha = 0.05,
      PanelWidth = 7L
    )
  }
  
  
  initial[["ComplexHeatmapPlot1"]] <- new(
    "ComplexHeatmapPlot",
    CustomRowsText = paste(features, collapse = "\n"),
    ColumnData = clusters,
    PanelWidth = 6L
  )
  
  initial[["ColumnDataPlot1"]] <- new(
    "ColumnDataPlot",
    YAxis = clusters,
    ColorBy = "Column data",
    ColorByColumnData = clusters,
    PanelWidth = 6L
  )


  return(initial)
  

}
