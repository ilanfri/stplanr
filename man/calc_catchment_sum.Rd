% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/catchmentArea.R
\name{calc_catchment_sum}
\alias{calc_catchment_sum}
\title{Calculate summary statistics for catchment area.}
\usage{
calc_catchment_sum(polygonlayer, targetlayer, calccols, distance = 500,
  projection = paste0("+proj=aea +lat_1=90 +lat_2=-18.416667",
  " +lat_0=0 +lon_0=10 +x_0=0 +y_0=0",
  " +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"),
  retainAreaProportion = FALSE)
}
\arguments{
\item{polygonlayer}{A SpatialPolygonsDataFrame containing zones from which
the summary statistics for the catchment variable will be calculated.
Smaller polygons will increase the accuracy of the results.}

\item{targetlayer}{A SpatialPolygonsDataFrame, SpatialLinesDataFrame,
SpatialPointsDataFrame, SpatialPolygons, SpatialLines or SpatialPoints
object containing the specifications of the facility for which the
catchment area is being calculated. If the object contains more than one
facility (e.g., multiple cycle paths) the aggregate catchment area will be
calculated.}

\item{calccols}{A vector of column names containing the variables in the
polygonlayer to be used in the calculation of the summary statistics for
the catchment area.}

\item{distance}{Defines the size of the catchment area as the distance
around the targetlayer in the units of the projection
(default = 500 metres)}

\item{projection}{The proj4string used to define the projection to be used
for calculating the catchment areas or a character string 'austalbers' to
use the Australian Albers Equal Area projection. Ignored if the polygonlayer
is projected in which case the targetlayer will be converted to the
projection used by the polygonlayer. In all cases the resulting object will
be reprojected to the original coordinate system and projection of the
polygon layer. Default is an Albers Equal Area projection but for more
reliable results should use a local projection (e.g., Australian Albers
Equal Area project).}

\item{retainAreaProportion}{Boolean value. If TRUE retains a variable in
the resulting SpatialPolygonsDataFrame containing the proportion of the
original area within the catchment area (Default = FALSE).}
}
\description{
Calculate summary statistics for catchment area.
}
\section{Details}{

Calculates the summary statistics for a catchment area of a facility
(e.g., cycle path) using straight-line distance from variables
available in a SpatialPolygonsDataFrame with census tracts or other
zones. Assumes that the frequency of the variable is evenly distributed
throughout the zone. Returns either a single value if calccols is of
length = 1, or a named vector otherwise.
}
\examples{
\dontrun{
data_dir <- system.file("extdata", package = "stplanr")
unzip(file.path(data_dir, 'smallsa1.zip'))
unzip(file.path(data_dir, 'testcycleway.zip'))
sa1income <- readOGR(".","smallsa1")
testcycleway <- readOGR(".","testcycleway")
calc_catchment_sum(
   polygonlayer = sa1income,
   targetlayer = testcycleway,
   calccols = c('Total'),
   distance = 800,
   projection = 'austalbers'
)

calc_catchment_sum(
polygonlayer = sa1income,
targetlayer = testcycleway,
calccols = c('Total'),
distance = 800,
projection = 'austalbers'
)
}
}

