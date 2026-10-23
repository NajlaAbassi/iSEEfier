#' iSEEnrich
#'
#' `iSEEnrich()` creates an initial state of an iSEE instance for interactive
#' exploration of feature sets extracted from GO and KEGG database, displaying
#' all associated genes in a `RowDataTable` panel.
#'
#' @param sce SingleCellExperiment object
#' @param collection A character vector specifying the gene set collections of
#'   interest (GO,KEGG)
#' @param organism A character string of the org.*.eg.db package to use to
#'   extract mappings of gene sets to gene IDs.
#' @param gene_identifier A character string specifying the identifier to use to
#'   extract gene IDs for the organism package
#'  
#' @param clusters A character string containing the name of the
#'   clusters/cell-type/state...(as listed in the colData of the sce)
#'   
#' @param groups A character string of the groups/conditions...(as it appears in
#'   the colData of the sce)
#'   
#' @param reddim_type A string vector containing the dimensionality reduction
#'   type
#'   
#'   
#' @return A list of "Panel" objects specifying the initial state of iSEE
#'   instance
#' @export iSEEnrich
#' @importFrom iSEEu createGeneSetCommands
#' @importFrom iSEEu registerFeatureSetCommands
#' @importFrom BiocBaseUtils isScalarCharacter
#'
#'
#' @examples
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' GO_collection <- "GO"
#' Mm_organism <- "org.Mm.eg.db"
#' gene_id <- "SYMBOL"
#' clusters <- "stimulus"
#' groups <- "single cell quality"
#' reddim_type <- "PCA"
#' results <- iSEEnrich(sce = sce,
#'                      collection = GO_collection,
#'                      organism = Mm_organism,
#'                      gene_identifier = gene_id,
#'                      clusters = clusters,
#'                      groups = groups,
#'                      reddim_type = reddim_type)
#' 
iSEEnrich <- function(sce,
                      collection = c("GO", "KEGG"),
                      organism = "org.Hs.eg.db",
                      gene_identifier = "ENTREZID",
                      clusters = colnames(colData(sce))[1],
                      groups = colnames(colData(sce))[1],
                      reddim_type = "PCA") {

  ## Checks on arguments
  if (!is(sce, "SingleCellExperiment"))
    stop("Please provide a SingleCellExperiment as input!")

  stopifnot(isScalarCharacter(collection))

  collection <- match.arg(collection, c("GO", "KEGG"))

  stopifnot(isScalarCharacter(organism))

  stopifnot(isScalarCharacter(gene_identifier))
  
  stopifnot(isScalarCharacter(clusters))
  
  stopifnot(isScalarCharacter(groups))
  
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
  
  if (!(reddim_type %in% reducedDimNames(sce))) {
    available_reddims <- reducedDimNames(sce)
    stop("The selected reduced dimensionality embedding is not available!\n",
         "Please select one of these: ",
         paste(available_reddims, collapse = ", "))
  }
  
  if (!requireNamespace(organism, quietly = TRUE))
    stop("Please check the value of the provided orgDb package ",
         "(the package needs to be installed)...",
         "If you want to install it run the following line:\n",
         "BiocManager::install('", organism,"')")


  initial <- list()

  cmds <- createGeneSetCommands(collections = collection,
                                organism = organism,
                                identifier = gene_identifier)
  sce1 <- registerFeatureSetCommands(sce, cmds)
  
  initial[["FeatureSetTable1"]] <- new(
    "FeatureSetTable", Collection = collection)
  
  initial[["RowDataTable1"]] <- new(
    "RowDataTable", RowSelectionSource = "FeatureSetTable1")
  
  initial[["FeatureAssayPlot1"]] <- new(
    "FeatureAssayPlot",
    XAxis = "Column data",
    XAxisColumnData = groups,
    YAxisFeatureSource = "RowDataTable1",
    ColorBy = "Column data",
    ColorByColumnData = groups,
    ColumnSelectionSource = "ColumnDataPlot1")
  
  initial[["ColumnDataPlot1"]] <- new(
    "ColumnDataPlot",
    XAxis = "Column data",
    YAxis = clusters,
    XAxisColumnData = groups,
    ColorByColumnData = clusters,
    ColorBy = "Column data"
    
  )
  
  initial[["ReducedDimensionPlot1"]] <- new(
    "ReducedDimensionPlot",
    Type = reddim_type,
    FacetColumnByColData = groups,
    FacetColumnBy = "Column data",
    ColorBy = "Feature name",
    ColorByFeatureSource = "RowDataTable1",
    ColumnSelectionSource = "ColumnDataPlot1"
  )
  
  initial[["MarkdownBoard1"]] <- new(
    "MarkdownBoard",
    Content = "# Placeholder\n\nFill me with genes, or anything!")
  

  return(
    list(
      initial = initial,
      sce = sce1
    )
  )
}
