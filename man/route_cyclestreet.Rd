% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/routes.R
\name{route_cyclestreet}
\alias{route_cyclestreet}
\title{Plan a single route with CycleStreets.net}
\usage{
route_cyclestreet(from, to, plan = "fastest", silent = TRUE, pat = NULL,
  base_url = "http://www.cyclestreets.net", reporterrors = FALSE,
  save_raw = "FALSE")
}
\arguments{
\item{from}{Text string or coordinates (a numeric vector of
\code{length = 2} representing latitude and longitude) representing a point
on Earth.}

\item{to}{Text string or coordinates (a numeric vector of
\code{length = 2} representing latitude and longitude) representing a point
on Earth. This represents the destination of the trip.}

\item{plan}{Text strong of either "fastest", "quietest" or "balanced"}

\item{silent}{Logical (default is FALSE). TRUE hides request sent.}

\item{pat}{The API key used. By default this is set to NULL and
this is usually aquired automatically through a helper, api_pat().}

\item{base_url}{The base url from which to construct API requests
(with default set to main server)}

\item{reporterrors}{Boolean value (TRUE/FALSE) indicating if cyclestreets
should report errors (FALSE by default).}

\item{save_raw}{Boolean value which returns raw list from the json if TRUE (FALSE by default).}
}
\description{
Provides an R interface to the CycleStreets.net cycle planning API,
a route planner made by cyclists for cyclists.
The function returns a SpatialLinesDataFrame object representing the
an estimate of the fastest, quietest or most balance route.
Currently only works for the United Kingdom and part of continental Europe.
See \url{http://www.cyclestreets.net/api/}for more information.
}
\details{
This function uses the online routing service
CycleStreets.net to find routes suitable for cyclists
between origins and destinations. Requires an
internet connection, a CycleStreets.net API key
and origins and destinations within the UK to run.

Note that if \code{from} and \code{to} are supplied as
character strings (instead of lon/lat pairs), Google's
geo-coding services are used via \code{RgoogleMaps::getGeoCode()}.

You need to have an api key for this code to run.
Loading a locally saved copy of the api key text string
before running the function, for example, will ensure it
is available on any computer:

\code{
mytoken <- readLines("~/Dropbox/dotfiles/cyclestreets-api-key-rl")
Sys.setenv(CYCLESTREET = mytoken)
}

if you want the API key to be available in future
sessions, set it using the .Renviron file
e.g. on Linux machines in bash via:

\code{
echo "CYCLESTREET=f3fe3d078ac34737" >> ~/.Renviron
}

Read more about the .Renviron here: \code{?.Renviron}
}
\examples{

\dontrun{
# Example from
from = c(0.117950, 52.205302); to = c(0.131402, 52.221046)
json_output = route_cyclestreet(from = from, to = to, plan = "quietest", save_raw = TRUE)
str(json_output) # what does cyclestreets give you?
names(json_output$marker$`@attributes`)
json_output$marker$`@attributes`$start[1] # starting point
json_output$marker$`@attributes`$finish[1] # end point
json_output$marker$`@attributes`$speed[1] # assumed speed (km/hr)
json_output$marker$`@attributes`$busynance # busyness of each section
json_output$marker$`@attributes`$elevations # list of elevations
# jsonlite::toJSON(json_output, pretty = TRUE) # complete json output (long!)
# Plan the 'fastest' route between two points in Manchester
rf_mcr <- route_cyclestreet(from = "M3 4EE", to = "M1 4BT", plan = "fastest")
rf_mcr@data
plot(rf_mcr)
(rf_mcr$length / (1000 * 1.61)) / # distance in miles
  (rf_mcr$time / (60 * 60)) # time in hours - average speed here: ~8mph
# Plan the 'quietest' route from Hereford to Leeds
rqh <- route_cyclestreet(from = "Hereford", to = "Leeds", plan = "quietest")
plot(rq_hfd)
# Plan a 'balanced' route from Pedaller's Arms to the University of Leeds
rb_pa <- route_cyclestreet("Pedaller's Arms, Leeds", "University of Leeds", "balanced")
# A long distance route (max = 500 km)
woodys_route = route_cyclestreet(from = "Stokesley", plan = "fastest", to = "Leeds")
# Plan a route between two lat/lon pairs in the UK
route_cyclestreet(c(-2, 52), c(-1, 53), "fastest")
}
}
\seealso{
line2route
}

