#' View an initial object as a set of tiles
#'
#' Previews the layout of the `initial` configuration object in a graphical form.
#'
#' Tiles are used to represent the panel types, and reflect the values of their
#' width.
#' This can be a compact visualization to obtain an overview for the configuration,
#' without the need of fully launching the app and loading the content of all
#' panels
#'
#' @details
#' This function is particularly useful with mid-to-large `initial` objects, as
#' they can be quickly generated in a programmatic manner via the `iSEEinit()`
#' provided in this package.
#'
#'
#' @param initial An `initial` list object, in the format that is required to
#' be passed as a parameter in the call to [iSEE::iSEE()].
#'
#' @return A `ggplot` object, representing a schematic view for the `initial`
#' object.
#'
#' @export
#'
#' @importFrom stats na.omit
#' @importFrom ggplot2 ggplot aes geom_tile scale_fill_manual scale_y_discrete
#'  theme theme_void
#' @importFrom rlang .data
#' @importFrom BiocBaseUtils isCharacter
#'
#' @seealso [view_initial_network()]
#'
#' @examples
#' ## Load a dataset and preprocess this quickly
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' sce <- scater::runTSNE(sce)
#' ## Select some features and aspects to focus on
#' gene_list <- c("ENSMUSG00000026581",
#'                "ENSMUSG00000005087",
#'                "ENSMUSG00000015437")
#' cluster <- "stimulus"
#' group <- "single cell quality"
#' initial <- iSEEinit(sce = sce,
#'                     features = gene_list,
#'                     clusters = cluster,
#'                     groups = group)
#'
#' view_initial_tiles (initial)
#'
#' ## Continue your exploration directly within iSEE!
#' if (interactive())
#'   iSEE(sce, initial = initial)
view_initial_tiles <- function(initial) {

  panel_widths <- vapply(initial,
                         function(arg) {
                           arg@PanelWidth
                         },
                         FUN.VALUE = numeric(1))

  # check: max value should be 12 (but it is a given through iSEE)
  panel_types <- vapply(initial, class, character(1))

  total_tiles <- sum(panel_widths)

  nr_rows <- ceiling(total_tiles / 12)

  # pre-fill all with white
  tiles_vector <- rep("white", nr_rows * 12)
  panel_vector <- rep(NA, nr_rows * 12)

  cur_rowpos <- 0
  abs_pos <- 0
  cur_row <- 1

  # fill in the tiles vector "with the rule of 12"
  for (i in seq_len(length(initial))) {
    this_width <- panel_widths[i]
    this_paneltype <- panel_types[i]
    this_color <- iSEE_panel_colors[this_paneltype]

    max_end <- cur_row * 12 # for each row, to be updated

    tiles_start <- abs_pos + 1
    tiles_end <- abs_pos + this_width

    if (tiles_end <= max_end) {
      # color as usual, update current position(s)
      tiles_vector[tiles_start:tiles_end] <- this_color
      panel_vector[tiles_start:tiles_end] <- this_paneltype
      cur_rowpos <- cur_rowpos + this_width
      abs_pos <- abs_pos + this_width

    } else {
      # re-start from the position in the new row
      cur_row <- cur_row + 1
      cur_rowpos <- 0
      abs_pos <- (cur_row - 1) * 12

      # update tiles start
      tiles_start <- abs_pos + 1
      tiles_end <- abs_pos + this_width

      # color, and update as usual
      tiles_vector[tiles_start:tiles_end] <- this_color
      panel_vector[tiles_start:tiles_end] <- this_paneltype
      cur_rowpos <- cur_rowpos + this_width
      abs_pos <- abs_pos + this_width
    }

  }

  # if needed, might require extra rows...
  if (cur_row > nr_rows) {
    # fill with white & NA the dedicated vectors
    tiles_vector[(abs_pos + 1):(cur_row * 12)] <- "white"
    panel_vector[(abs_pos + 1):(cur_row * 12)] <- NA
  }


  waffled_matrix_long <- expand.grid(seq_len(12), seq_len(cur_row))
  waffled_matrix_long$Var1 <- as.factor(waffled_matrix_long$Var1)
  waffled_matrix_long$Var2 <- as.factor(waffled_matrix_long$Var2)
  waffled_matrix_long$panel_color <- tiles_vector
  waffled_matrix_long$panel_type <- panel_vector

  p <- ggplot(na.omit(waffled_matrix_long),
              aes(x = .data$Var1,
                  y = .data$Var2)) +
    geom_tile(aes(fill = .data$panel_type), col = "white") +
    scale_y_discrete(limits = rev(levels(waffled_matrix_long$Var2))) +
    theme_void() +
    scale_fill_manual(
      name = "iSEE Panel type",
      values = iSEE_panel_colors
    ) +
    theme(legend.position = "bottom")

  return(p)
}


#' View an initial object as a network
#'
#' Translates the layout of the `initial` configuration object as a networks,
#' representing panels as nodes and links between them as edges.
#'
#' Panels are the nodes, with color and names to identify them easily.
#' The connections among panels are represented through directed edges.
#' This can be a compact visualization to obtain an overview for the configuration,
#' without the need of fully launching the app and loading the content of all
#' panels
#'
#' @details
#' This function is particularly useful with mid-to-large `initial` objects, as
#' they can be quickly generated in a programmatic manner via the `iSEEinit()`
#' provided in this package.
#'
#' @param initial An `initial` list object, in the format that is required to
#' be passed as a parameter in the call to [iSEE::iSEE()].
#' @param plot_format Character string, one of `igraph`, `visNetwork`, or `none`.
#' Defaults to `igraph`. Determines the format of the visual representation
#' generated as a side effect of this function - it can be the output of the
#' `plot()` function for `igraph` objects, or an interactive widget created
#' via `visNetwork::visNetwork()`.
#'
#' @return An `igraph` object, underlying the visual representation provided.
#'
#' @export
#'
#' @importFrom igraph graph_from_data_frame graph.empty V V<-
#' @importFrom visNetwork visNetwork visEdges toVisNetworkData
#'
#' @seealso [view_initial_tiles()]
#'
#' @examples
#' ## Load a dataset and preprocess this quickly
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' sce <- scater::runTSNE(sce)
#' ## Select some features and aspects to focus on
#' gene_list <- c("ENSMUSG00000026581", "ENSMUSG00000005087", "ENSMUSG00000015437")
#' cluster <- "stimulus"
#' group <- "single cell quality"
#' initial <- iSEEinit(sce = sce,
#'                     features = gene_list,
#'                     clusters = cluster,
#'                     groups = group)
#'
#' g_init <- view_initial_network(initial)
#' g_init
#'
#' view_initial_network(initial, plot_format = "visNetwork")
#'
#' ## Continue your exploration directly within iSEE!
#' if (interactive())
#'   iSEE(sce, initial = initial)
view_initial_network <- function(initial,
                              plot_format = c("igraph", "visNetwork", "none")) {

  plot_format <- match.arg(plot_format, c("igraph", "visNetwork", "none"))

  panel_widths <- vapply(initial,
                         function(arg) {
                           arg@PanelWidth
                         },
                         FUN.VALUE = numeric(1))

  # check: max value should be 12 (but it is a given through iSEE)
  panel_types <- vapply(initial, class, character(1))

  # need to have SIMPLIFIED configs
  panel_ids <- names(initial)

  panel_links <- vapply(initial,
                        function(arg) {
                          arg@ColumnSelectionSource
                        },
                        FUN.VALUE = character(1))
  panel_edges <- panel_links[panel_links != "---"]

  graph_nodes_df <- data.frame(
    name = panel_ids
  )

  if (length(panel_edges) > 0) {
    graph_edges_df <- data.frame(
      from = names(panel_edges),
      to = panel_edges
    )
    g <- graph_from_data_frame(graph_edges_df, vertices = graph_nodes_df)
  } else {
    g <- graph.empty(n = length(panel_ids))
    V(g)$name <- panel_ids
  }

  V(g)$color <- iSEE_panel_colors[panel_types]

  if (plot_format == "igraph") {
    plot(g, vertex.label.family = "Helvetica")
  } else if (plot_format == "visNetwork") {
    gdata <- visNetwork::toVisNetworkData(g)
    print(visNetwork(nodes = gdata$nodes,
               edges = gdata$edges) |>
      visEdges(arrows = "to",
               smooth = TRUE))
  } else if (plot_format == "none") {
    message("Returning the graph object...")
  }
  return(g)
}




#' Glue together initial objects into one
#'
#' Glue a set of `initial` configuration objects, combining them into a single
#' valid `initial` set.
#'
#' @param ... A set of `initial` list objects (in the format that is required to
#' be passed as a parameter in the call to [iSEE::iSEE()]) - just as in the
#' behavior of the `c()`/`paste()` function
#' @param remove_duplicate_panels Logical, defaults to `TRUE`. Defines the behavior
#' to remove panels detected as duplicated. Can be relevant upon concatenating
#' mid to large sets of panels.
#' @param verbose Logical, defaults to `TRUE`. If on, prints out a series of
#' informative messages to describe the actions undertaken upon running.
#' @param custom_panels_allowed Character vector, defaults to `NULL`. Can be used
#' to specify additional panels to be allowed in the concatenation.
#'
#' @details
#' The usage of `custom_panels_allowed` can be especially relevant when one creates
#' one or more custom panels, with a specific name that needs to be indicated in
#' this parameter.
#' For example, if using a panel of class `FancyPlotPanel` and one called
#' `FancyTablePanel`, the value for `custom_panels_allowed` should be set to
#' `c("FancyPlotPanel", "FancyTablePanel")`.
#'
#' It is worth mentioning that [iSEE::iSEE()] is actually able to handle the
#' automatic renaming of panels that could be detected as duplicated. This can
#' basically relax the requirement on the "uniqueness" of the configured panels, with
#' the only caveat of having to think of how the *transmissions* between panels
#' will be handled; nevertheless, most users might not even need to face this
#' situation.
#'
#' @return A single `initial` list object, in the format that is required to
#' be passed as a parameter in the call to [iSEE::iSEE()], concatenating the
#' values provided as input.
#'
#' @export
#'
#' @examples
#' ## Load a dataset and preprocess this quickly
#' sce <- scRNAseq::RichardTCellData()
#' sce <- scrapper::normalizeRnaCounts.se(sce)
#' sce <- scater::runPCA(sce)
#' sce <- scater::runTSNE(sce)
#' ## Select some features and aspects to focus on
#' gene_list_1 <- c("ENSMUSG00000026581")
#' gene_list_2 <- c("ENSMUSG00000005087", "ENSMUSG00000015437")
#' cluster <- "stimulus"
#' group <- "single cell quality"
#' initial1 <- iSEEinit(sce = sce,
#'                      features = gene_list_1,
#'                      clusters = cluster,
#'                      groups = group)
#' initial2 <- iSEEinit(sce = sce,
#'                      features = gene_list_2,
#'                      clusters = cluster,
#'                      groups = group)
#' initials_merged <- glue_initials(initial1,
#'                                  initial2)
#' view_initial_tiles(initial1)
#' view_initial_tiles(initial2)
#' view_initial_tiles(initials_merged)
#'
#' ## Continue your exploration directly within iSEE!
#' if (interactive())
#'   iSEE(sce, initial = initial_merged)
glue_initials <- function(...,
                         remove_duplicate_panels = TRUE,
                         verbose = TRUE,
                         custom_panels_allowed = NULL) {

  config_as_list <- list(...)

  allowed_panels <- names(iSEE_panel_colors)

  if (!is.null(custom_panels_allowed)) {
    stopifnot(isCharacter(custom_panels_allowed))
    allowed_panels <- c(allowed_panels, custom_panels_allowed)
  }

  # all things to be concatenated need to be lists ("initial" lists)
  if (!all(unlist(lapply(config_as_list, is.list))))
    stop("You need to provide a set of `initial` configuration lists for iSEE")

  nr_configs <- length(config_as_list)
  nr_panels <- lengths(config_as_list)

  if (verbose) {
    message(
      "Merging together ",
      nr_configs,
      " `initial` configuration objects...\n",
      "Combining sets of ",
      paste(nr_panels, collapse = ", "),
      " different panels."
    )
  }

  # checking that all the components are legit panel configurations
  concatenated_configs <- c(...)
  panel_types <- vapply(concatenated_configs, class, character(1))

  if (!all(panel_types %in% allowed_panels))
    stop("Some elements included in the provided input are not recognized as iSEE panels!")

  if (remove_duplicate_panels) {
    dupe_panels <- duplicated(concatenated_configs)
    glued_configs <- concatenated_configs[!dupe_panels]
    if (verbose)
      message("\nDropping ",
              sum(dupe_panels), " of the original list of ",
              length(concatenated_configs), " (detected as duplicated entries)"
      )
  } else {
    glued_configs <- concatenated_configs
  }

  if (verbose) {
    if (any(duplicated(names(glued_configs)))) {
      message("\nSome names of the panels were specified by the same name, ",
              "but this situation can be handled at runtime by iSEE\n",
              "(This is just a non-critical message)")
    }

    message("\nReturning an `initial` configuration including ",
            length(glued_configs),
            " different panels. Enjoy!\n",
            "If you want to obtain a preview of the panels configuration, ",
            "you can call `view_initial_tiles()` on the output of this function"
    )
  }

  return(glued_configs)
}



#' Constant values used throughout iSEEfier
#'
#' @name constants-iSEEfier
#' @return A character vector of length 17 containing color values used for
#' iSEE and iSEEu panels
#'
#' @section Panel colors:
#' * color values (as string character or hex value) for the panels included by
#'   default in `iSEE` and `iSEEu`
iSEE_panel_colors <- c(
  ReducedDimensionPlot = "#3565AA",
  FeatureAssayPlot = "#7BB854",
  SampleAssayPlot = "#07A274",
  ColumnDataPlot = "#DB0230",
  ColumnDataTable = "#B00258",
  RowDataPlot = "#F2B701",
  RowDataTable = "#E47E04",
  ComplexHeatmapPlot = "#440154FF",
  AggregatedDotPlot = "#703737FF",
  MarkdownBoard = "black",
  DynamicMarkerTable = "#B73CE4",
  DynamicReducedDimensionPlot = "#0F0F0F",
  FeatureSetTable = "#BB00FF",
  GeneSetTable = "#BB00FF",
  LogFCLogFCPlot = "#770055",
  MAPlot = "#666600",
  VolcanoPlot = "#DEAE10"
)
