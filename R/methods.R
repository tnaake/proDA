

#' Get different features and elements of the 'proDAFit' object
#'
#' The functions listed below can all be accessed using the
#' fluent dollar notation (ie. \code{fit$abundances[1:3,1:3]}) without
#' any additional parentheses.
#'
#'
#' @param object the 'proDAFit' object
#' @param formula specific argument for the \code{design} function
#'   to get the formula that was used to create the linear model.
#'   If no formula was used \code{NULL} is returned.
#'
#' @return See the documentation of the generics to find out what each method returns
#'
#' @name accessor_methods
NULL



#' @rdname accessor_methods
#' @export
setMethod("abundances", signature = "proDAFit", function(object){
  assays(object)[["abundances"]]
})



#' @rdname accessor_methods
#' @export
setMethod("design", signature = "proDAFit", function(object, formula = FALSE){
  if(formula){
    object@design_formula
  }else{
    object@design_matrix
  }
})


#' @rdname accessor_methods
#' @export
setMethod("hyper_parameters", signature = "proDAFit", function(object){
  list(location_prior_mean = object@location_prior_mean,
       location_prior_scale = object@location_prior_scale,
       location_prior_df = object@location_prior_df,
       variance_prior_scale = object@variance_prior_scale,
       variance_prior_df = object@variance_prior_df,
       dropout_curve_position = colData(object)$dropout_curve_position,
       dropout_curve_scale =  colData(object)$dropout_curve_scale)
})


#' @rdname accessor_methods
#' @export
setMethod("feature_parameters", signature = "proDAFit", function(object){
  rd <- rowData(object)
  as.data.frame(rd[, which(mcols(rd)$type == "feature_parameter"), drop=FALSE])
})


#' @rdname accessor_methods
#' @export
setMethod("coefficients", signature = "proDAFit", function(object){
  rd <- rowData(object)
  as.matrix(rd[, which(mcols(rd)$type == "coefficient"), drop=FALSE])
})

#' @rdname accessor_methods
#' @export
setMethod("coefficient_variance_matrices", signature = "proDAFit", function(object){
  rd <- rowData(object)
  n <- result_names(object)
  p <- length(n)
  lapply(rd[, which(mcols(rd)$type == "coefficient_variance"), drop=TRUE], function(elem){
    stopifnot(length(elem) == p^2)
    res <- matrix(elem, nrow=p, ncol=p)
    colnames(res) <- n
    rownames(res) <- n
    res
  })
})


#' @rdname accessor_methods
#' @export
setMethod("reference_level", signature = "proDAFit", function(object){
  object@reference_level
})

#' @rdname accessor_methods
#' @export
setMethod("convergence", signature = "proDAFit", function(object){
  object@convergence
})



setMethod("show", signature = "proDAFit", function(object){

  header <- "\tParameters of the probabilistic dropout model\n"

  size_descr <- paste0("The dataset contains ", ncol(object), " samples and ", nrow(object), " proteins")
  frac_miss <- sum(is.na(abundances(object))) / (ncol(object) * nrow(object))
  na_descr <- paste0(formatC(frac_miss * 100, digits = 3, width=1, format="g"), "% of the values are missing\n")
  formal_descr <- if(!is.null(form <- design(object, formula = TRUE))){
    paste0("Experimental design: y", format(form))
  }else{
    "Experimental design was specified using a design matrix (design(object))."
  }

  if(convergence(object)$successful){
    converged_txt <- "The model has successfully converged."
  }else{
    converged_txt <- paste0("Attention: the model has not converged.\n",
                            "The error in the last iteration (", convergence(object)$iteration, ") was ", sprintf("%.2g",convergence(object)$error), "\n",
                            "Please re-run the model with increased number of max_iter.")
  }

  hp <- object$hyper_parameters
  hyper_para_txt <- paste0("\nThe inferred parameters are:\n",
                           paste0(vapply(seq_along(hp), function(idx){
                             pretty_num <- if(names(hp)[idx] == "dropout_curve_scale"){
                               scales <- hp[[idx]][seq_len(min(length(hp[[idx]]), 4))]
                               ifelse(is.na(scales) | scales > -100,
                                      formatC(scales, digits=3, width=1, format="g"),
                                      "< -100")
                             }else if(names(hp)[idx] == "variance_prior_df"){
                               if(is.na(hp[[idx]]) || hp[[idx]] < 100){
                                 formatC(hp[[idx]][seq_len(min(length(hp[[idx]]), 4))], digits=3, width=1, format="g")
                               }else{
                                 "> 100"
                               }
                             }else{
                               formatC(hp[[idx]][seq_len(min(length(hp[[idx]]), 4))], digits=3, width=1, format="g")
                             }
                             paste0(names(hp)[idx], ":",
                                    paste0(rep(" ", times=24-nchar(names(hp)[idx])), collapse=""),
                                    paste0(pretty_num, collapse=", "),
                                    (if(length(hp[[idx]]) <= 4) "" else ", ..."))
                           }, FUN.VALUE = ""), collapse = "\n"))


  cat(paste0(c(header, size_descr, na_descr, formal_descr, converged_txt, hyper_para_txt), collapse = "\n"))


  invisible(NULL)
})

