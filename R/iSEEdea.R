#' iSEEdea
#' 
#' This function fetches available DEAs in a `DeeDeeExperiment` object, or
#' takes a `SingleCellExperiment` object with a list of contrasts and
#' reutrns ready-to-use configuration to explore DEA results with `iSEE`
#' and `iSEEde`
#'
#' @param sce A `SingleCellExperiment` or `DeeDeeExperiment` object
#' @param contrasts A character string of contrast names. To be used when `sce`
#' is a `DeeDeeExperiment` object
#' @param de_list A named list of DEA results (from `DESEq2`, `edgeR`,
#' or `limma`)
#'
#' @returns A list of "Panel" objects specifying the initial state of `iSEE`
#' instance, as well as the sce object with embedded DEA results compatible
#' with `iSEE`
#' @export
#'
#' @examples
#' # initial <- iSEEdea(sce = sce, de_list = list(dea1,dea2))
#' # iSEE(initial$sce,initial$initial)
iSEEdea <- function(sce,
                    contrasts = NULL,
                    de_list = NULL){
  if (!requireNamespace("iSEEde", quietly = TRUE)) {
    stop(
      "The 'iSEEde' package is required for iSEEdea(). Please install it."
    )
  }
  
  if (!inherits(sce, "SingleCellExperiment")) {
    stop("'sce' must be a SingleCellExperiment or DeeDeeExperiment object.")
  }
  
  if (!is.null(de_list)) {
    if (!is.list(de_list) || is.null(names(de_list)) ||
        length(de_list) == 0) {
      stop("'de_list' must be a non-empty named list of DEA results.")
    }
  }
  
  # extract available DEA names
  dea_names <- character(0)
  
  if (inherits(sce, "DeeDeeExperiment")) {
    
    if (!requireNamespace("DeeDeeExperiment", quietly = TRUE)) {
      stop("The 'DeeDeeExperiment' package is required.")
    }
    
    # extract DEAs from sce
    dea_names <- DeeDeeExperiment::getDEANames(sce)
  }
  
  # check already embedded contrasts
  embedded <- iSEEde::contrastResultsNames(sce)
  
  
  if (is.null(contrasts)) {
    
    if (!is.null(de_list)) {
      contrasts <- names(de_list)
    } else if (inherits(sce, "DeeDeeExperiment")) {
      contrasts <- dea_names
    } else {
      contrasts <- embedded
    }
  }
  
  if(!is.character(contrasts) || length(contrasts) == 0){
    stop("'contrasts' must be a non-empty character vector!")
  }
  
  # check all contrasts exist and if so check if it has the embedded format
  for (i in contrasts) {
    if (!(i %in% dea_names) && !(i %in% names(de_list))) {
      if (!(paste0("iSEEde_", i) %in% embedded)) {
        stop("Couldn't find contrast: ", i,
             ". Available DEAs: ", paste(dea_names, collapse = ", "))
      }
    }
  }
  
  # embed contrasts
  for (i in contrasts) {
    name <- paste0("iSEEde_", i)
    
    # if already embedded, skip
    if (name %in% embedded) { #need to chekc the default names of embedded coloumns
      next
    }
    
    if (!is.null(de_list) && i %in% names(de_list)) {
      dea <- de_list[[i]]
    } else {
      
      dea <- DeeDeeExperiment::getDEA(sce,
                                      dea_name = i,
                                      format = "original")
    }
    sce <- iSEEde::embedContrastResults(dea,
                                        se = sce,
                                        name = paste0("iSEEde_",i))
  }
  
  
  # create the initial state
  initial <- list()
  
  initial[["DETable1"]] <- iSEEde::DETable(
    ContrastName = paste0("iSEEde_", contrasts[1]),
    HiddenColumns = c("baseMean", "lfcSE", "stat"),
    PanelWidth = 4L
  )
  
  initial[["VolcanoPlot1"]] <- iSEEde::VolcanoPlot(
    ContrastName = paste0("iSEEde_", contrasts[1]),
    ColorByRowData = "gene_id",
    ColorByFeatureSource = "DETable1",
    PanelWidth = 4L
  )
  
  initial[["MAPlot1"]] <- iSEEde::MAPlot(ContrastName = 
                                           paste0("iSEEde_", contrasts[1]),
                                         PanelWidth = 4L)
  
  
  return(list(sce = sce, initial = initial))
}
