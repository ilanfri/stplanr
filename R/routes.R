#' Plan a single route with CycleStreets.net
#'
#' Provides an R interface to the CycleStreets.net cycle planning API,
#' a route planner made by cyclists for cyclists.
#' The function returns a SpatialLinesDataFrame object representing the
#' an estimate of the fastest, quietest or most balance route.
#' Currently only works for the United Kingdom and part of continental Europe.
#' See \url{http://www.cyclestreets.net/api/}for more information.
#'
#' @param from Text string or coordinates (a numeric vector of
#'  \code{length = 2} representing latitude and longitude) representing a point
#'  on Earth.
#'
#' @param to Text string or coordinates (a numeric vector of
#'  \code{length = 2} representing latitude and longitude) representing a point
#'  on Earth. This represents the destination of the trip.
#'
#' @param plan Text strong of either "fastest", "quietest" or "balanced"
#' @param silent Logical (default is FALSE). TRUE hides request sent.
#' @param pat The API key used. By default this is set to NULL and
#' this is usually aquired automatically through a helper, api_pat().
#'
#' @details
#'
#' This function uses the online routing service
#' CycleStreets.net to find routes suitable for cyclists
#' between origins and destinations. Requires an
#' internet connection, a CycleStreets.net API key
#' and origins and destinations within the UK to run.
#'
#' Note that if \code{from} and \code{to} are supplied as
#' character strings (instead of lon/lat pairs), Google's
#' geo-coding services are used via \code{RgoogleMaps::getGeoCode()}.
#'
#' You need to have an api key for this code to run.
#' Loading a locally saved copy of the api key text string
#' before running the function, for example, will ensure it
#' is available on any computer:
#'
#' \code{
#' mytoken <- readLines("~/Dropbox/dotfiles/cyclestreets-api-key-rl")
#' Sys.setenv(CYCLESTREET = mytoken)
#' }
#'
#' if you want the API key to be available in future
#' sessions, set it using the .Renviron file
#' e.g. on Linux machines in bash via:
#'
#' \code{
#' echo "CYCLESTREET=f3fe3d078ac34737" >> ~/.Renviron
#' }
#'
#' Read more about the .Renviron here: \code{?.Renviron}
#'
#'
#' @inheritParams line2route
#' @param base_url The base url from which to construct API requests
#' (with default set to main server)
#' @param reporterrors Boolean value (TRUE/FALSE) indicating if cyclestreets
#' should report errors (FALSE by default).
#' @param save_raw Boolean value which returns raw list from the json if TRUE (FALSE by default).
#' @export
#' @seealso line2route
#' @examples
#'
#' \dontrun{
#' # Example from
#' from = c(0.117950, 52.205302); to = c(0.131402, 52.221046)
#' json_output = route_cyclestreet(from = from, to = to, plan = "quietest", save_raw = TRUE)
#' str(json_output) # what does cyclestreets give you?
#' names(json_output$marker$`@attributes`)
#' json_output$marker$`@attributes`$start[1] # starting point
#' json_output$marker$`@attributes`$finish[1] # end point
#' json_output$marker$`@attributes`$speed[1] # assumed speed (km/hr)
#' json_output$marker$`@attributes`$busynance # busyness of each section
#' json_output$marker$`@attributes`$elevations # list of elevations
#' # jsonlite::toJSON(json_output, pretty = TRUE) # complete json output (long!)
#' # Plan the 'fastest' route between two points in Manchester
#' rf_mcr <- route_cyclestreet(from = "M3 4EE", to = "M1 4BT", plan = "fastest")
#' rf_mcr@data
#' plot(rf_mcr)
#' (rf_mcr$length / (1000 * 1.61)) / # distance in miles
#'   (rf_mcr$time / (60 * 60)) # time in hours - average speed here: ~8mph
#' # Plan the 'quietest' route from Hereford to Leeds
#' rqh <- route_cyclestreet(from = "Hereford", to = "Leeds", plan = "quietest")
#' plot(rq_hfd)
#' # Plan a 'balanced' route from Pedaller's Arms to the University of Leeds
#' rb_pa <- route_cyclestreet("Pedaller's Arms, Leeds", "University of Leeds", "balanced")
#' # A long distance route (max = 500 km)
#' woodys_route = route_cyclestreet(from = "Stokesley", plan = "fastest", to = "Leeds")
#' # Plan a route between two lat/lon pairs in the UK
#' route_cyclestreet(c(-2, 52), c(-1, 53), "fastest")
#' }
route_cyclestreet <- function(from, to, plan = "fastest", silent = TRUE, pat = NULL,
                              base_url = "http://www.cyclestreets.net", reporterrors = FALSE,
                              save_raw = "FALSE"){

  # Convert sp object to lat/lon vector
  if(class(from) == "SpatialPoints" | class(from) == "SpatialPointsDataFrame" )
    from <- coordinates(from)
  if(class(to) == "SpatialPoints" | class(to) == "SpatialPointsDataFrame" )
    to <- coordinates(to)

  # Convert character strings to lon/lat if needs be
  if(is.character(from))
    from <- rev(RgoogleMaps::getGeoCode(from))
  if(is.character(to))
    to <- rev(RgoogleMaps::getGeoCode(to))

  orig <- paste0(from, collapse = ",")
  dest <- paste0(to, collapse = ",")
  ft_string <- paste(orig, dest, sep = "|")

  if(is.null(pat))
    pat = api_pat("cyclestreet")

  httrmsg = httr::modify_url(
    base_url,
    path = "api/journey.json",
    query = list(
      key = pat,
      itinerarypoints = ft_string,
      plan = plan,
      reporterrors = ifelse(reporterrors == TRUE, 1, 0)
    )
  )

  if (silent == FALSE) {
    print(paste0("The request sent to cyclestreets.net was: ", httrmsg))
  }

  httrreq <- httr::GET(httrmsg)

  if (grepl('application/json', httrreq$headers$`content-type`) == FALSE) {
    stop("Error: Cyclestreets did not return a valid result")
  }

  txt <- httr::content(httrreq, as = "text", encoding = "UTF-8")
  if (txt == "") {
    stop("Error: Cyclestreets did not return a valid result")
  }

  obj <- jsonlite::fromJSON(txt)

  if (is.element("error", names(obj))) {
    stop(paste0("Error: ", obj$error))
  }

  if(save_raw){
    return((obj))
  }else{
    # obj$marker$`@attributes`$elevations
    # obj$marker$`@attributes`$points
    coords <- obj$marker$`@attributes`$coordinates[1]
    coords <- stringr::str_split(coords, pattern = " |,")[[1]]
    coords <- matrix(as.numeric(coords), ncol = 2, byrow = TRUE)

    route <- sp::SpatialLines(list(sp::Lines(list(sp::Line(coords)), ID = 1)))
    h <-  obj$marker$`@attributes`$elevations # hilliness
    h <- stringr::str_split(h, pattern = ",")
    h <- as.numeric(unlist(h)[-1])
    htot <- sum(abs(diff(h)))

    # busyness overall
    bseg <- obj$marker$`@attributes`$busynance
    bseg <- stringr::str_split(bseg, pattern = ",")
    bseg <- as.numeric(unlist(bseg)[-1])
    bseg <- sum(bseg)

    df <- data.frame(
      plan = obj$marker$`@attributes`$plan[1],
      start = obj$marker$`@attributes`$start[1],
      finish = obj$marker$`@attributes`$finish[1],
      length = as.numeric(obj$marker$`@attributes`$length[1]),
      time = as.numeric(obj$marker$`@attributes`$time[1]),
      waypoint = nrow(coords),
      change_elev = htot,
      av_incline = htot / as.numeric(obj$marker$`@attributes`$length[1]),
      co2_saving = as.numeric(obj$marker$`@attributes`$grammesCO2saved[1]),
      calories = as.numeric(obj$marker$`@attributes`$calories[1]),
      busyness = bseg
    )

    row.names(df) <- route@lines[[1]]@ID
    route <- sp::SpatialLinesDataFrame(route, df)
    proj4string(route) <- CRS("+init=epsg:4326")
    route
  }
}
#' Plan a route with the graphhopper routing engine
#'
#' Provides an R interface to the graphhopper routing engine,
#' an open source route planning service.
#'
#' The function returns a SpatialLinesDataFrame object.
#' See \url{https://github.com/graphhopper} for more information.
#'
#' @param vehicle A text string representing the vehicle. Can be bike, bike2, car
#' or foot.
#'
#' @details
#'
#' To test graphopper is working for you, try something like this, but with
#' your own API key:
#' To use this function you will need to obtain an API key from
#' \url{https://graphhopper.com/#directions-api}.
#' It is assumed that you have set your api key as a system environment
#' for security reasons (so you avoid typing the API key in your code).
#' Do this by adding the following to your .Renviron file (see \code{?.Renviron}
#' or \url{https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html}
#' for more on this):
#'
#' \code{GRAPHHOPPER='FALSE-Key-eccbf612-214e-437d-8b73-06bdf9e6877d'}.
#'
#' (Note: key not real, use your own key.)
#'
#' \code{obj <- jsonlite::fromJSON(url)}
#'
#' Where \code{url} is an example api request from
#'  \url{https://github.com/graphhopper/directions-api/blob/master/routing.md}.
#'
#' @inheritParams route_cyclestreet
#' @export
#' @seealso route_cyclestreet
#' @examples
#' \dontrun{
#' r <- route_graphhopper(from = "Leeds", to = "Dublin", vehicle = "bike")
#' r@data
#' plot(r)
#' r <- route_graphhopper("New York", "Washington", vehicle = "foot")
#' plot(r)
#' }
route_graphhopper <- function(from, to, vehicle = "bike", silent = TRUE, pat = NULL, base_url = "https://graphhopper.com"){

  # Convert character strings to lon/lat if needs be
  if(is.character(from) | is.character(to)){
    from <- rev(RgoogleMaps::getGeoCode(from))
    to <- rev(RgoogleMaps::getGeoCode(to))
  }

  if(is.null(pat))
    pat = api_pat("graphhopper")

  httrmsg = httr::modify_url(
    base_url,
    path = "/api/1/route",
    query = list(
      point = paste0(from[2:1], collapse = ","),
      point = paste0(to[2:1], collapse = ","),
      vehicle = vehicle,
      locale = "en-US",
      debug = 'true',
      points_encoded = 'false',
      key = pat
    )
  )
  if(silent == FALSE){
    print(paste0("The request sent was: ", httrmsg))
  }
  httrreq <- httr::GET(httrmsg)
  httr::stop_for_status(httrreq)

  if (grepl('application/json', httrreq$headers$`content-type`) == FALSE) {
    stop("Error: Graphhopper did not return a valid result")
  }

  txt <- httr::content(httrreq, as = "text", encoding = "UTF-8")
  if (txt == "") {
    stop("Error: Graphhopper did not return a valid result")
  }

  obj <- jsonlite::fromJSON(txt)

  if (is.element("message", names(obj))) {
    if (grepl("Wrong credentials", obj$message) == TRUE) {
      stop("Invalid API key")
    }
  }
  route <- sp::SpatialLines(list(sp::Lines(list(sp::Line(obj$paths$points[[1]][[1]][,1:2])), ID = "1")))

  climb <- NA # to set elev variable up

  # get elevation data if it was a bike trip
  if(vehicle == "bike"){
    change_elev <- obj$path$descend + obj$paths$ascend
  }else{
    change_elev <- NA
  }

  # Attribute data for the route
  df <- data.frame(
    time = obj$paths$time / (1000 * 60),
    dist = obj$paths$distance,
    change_elev = change_elev
  )

  route <- sp::SpatialLinesDataFrame(route, df)
  proj4string(route) <- CRS("+init=epsg:4326")
  route

}

#' Retrieve personal access token.
#'
#' @param api_name Text string of the name of the API you are calling, e.g.
#' cyclestreet, graphhopper etc.
#'
#' @keywords internal
#' @export
#' @examples
#' \dontrun{
#' api_pat(api_name = "cyclestreet")
#' }
api_pat <- function(api_name, force = FALSE) {
  api_name_caps = toupper(api_name)
  env <- Sys.getenv(api_name_caps)
  if (!identical(env, "") && !force) return(env)

  if (!interactive()) {
    stop(paste0("Set the environment variable ",  api_name_caps, " e.g. with .Renviron or Sys.setenv()"),
         call. = FALSE)
  }

  message("Couldn't find the environment variable ",  api_name_caps, ". See documentation, e.g. ?route_cyclestreet, for more details.")
  message("Please enter your API key to access the ", api_name, "and press enter:")
  pat <- readline(": ")

  if (identical(pat, "")) {
    stop("Personal access token entry failed", call. = FALSE)
  }

  message("Updating ",  api_name_caps, " environment variable. Save this to .Renviron for future use.")
  Sys.setenv(api_name_caps = pat)

  pat

}