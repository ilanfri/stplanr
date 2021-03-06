% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/overline.R
\name{onewayid}
\alias{onewayid}
\title{Aggregate ods so they become non-directional, e.g. by summing travel in both directions.}
\usage{
onewayid(x, attrib, id1 = names(x)[1], id2 = names(x)[2])
}
\arguments{
\item{x}{A data frame, representing an OD matrix}

\item{attrib}{A vector of column numbers or names
for deciding which attribute(s) of class numeric to
aggregate}

\item{id1}{Optional (it is assumed to be the first column)
text string referring to the name of the variable containing
the unique id of the origin}

\item{id2}{Optional (it is assumed to be the second column)
text string referring to the name of the variable containing
the unique id of the destination}
}
\value{
\code{onewayid} outputs a data.frame with rows containing
results for the user-selected attribute values that have been aggregated.
}
\description{
Flow data often contains movement in two directions: from point A to point B
and then from B to A. This can be problematic for transport planning, because
the magnitude of flow along a route can be masked by flows the other direction.
If only the largest flow in either direction is captured in an analysis, for
example, the true extent of travel will by heavily under-estimated for
OD pairs which have similar amounts of travel in both directions.
Flows in both direction are often represented by overlapping lines with
identical geometries (see \code{\link{flowlines}}) which can be confusing
for users and are difficult to plot.
}
\details{
This function aggregates directional flows into non-directional flows,
potentially halving the number of lines objects and reducing the number
of overlapping lines to zero.
}
\examples{
data("flow")
flow_oneway = onewayid(flow, attrib = 3)
nrow(flow_oneway) < nrow(flow) # result has fewer rows
sum(flow$All) == sum(flow_oneway$All) # but the same total flow
# using names instead of index for attribute
onewayid(flow, attrib = "All")
# using many attributes to aggregate
attrib = which(vapply(flow, is.numeric, TRUE))
flow_oneway = onewayid(flow, attrib = attrib)
colSums(flow_oneway[attrib]) == colSums(flow[attrib]) # test if the colSums are equal
# Demonstrate the results from onewayid and onewaygeo are identical
flow_oneway_geo = onewaygeo(flowlines, attrib = attrib)
plot(flow_oneway$All, flow_oneway_geo$All)
}

