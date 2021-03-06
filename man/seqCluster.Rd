% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqCluster.R
\name{seqCluster}
\alias{seqCluster}
\title{Program for sequentially clustering, removing cluster, and starting again.}
\usage{
seqCluster(x = NULL, diss = NULL, k0, clusterFunction = c("tight",
  "hierarchical01", "pam", "hierarchicalK"), subsample = TRUE, beta = 0.7,
  top.can = 15, remain.n = 30, k.min = 3, k.max = k0 + 10,
  verbose = TRUE, subsampleArgs = NULL, clusterDArgs = NULL)
}
\arguments{
\item{x}{\code{p x n} data matrix on which to run the clustering (samples in
columns).}

\item{diss}{\code{n x n} data matrix of dissimilarities between the samples
on which to run the clustering}

\item{k0}{the value of K at the first iteration of sequential algorithm, see
details below or vignette.}

\item{clusterFunction}{passed to clusterDMat option 'clusterFunction' to
indicate method of clustering, see \code{\link{clusterD}}.}

\item{subsample}{logical as to whether to subsample via 
\code{\link{subsampleClustering}} to get the distance matrix at each 
iteration; otherwise the distance matrix is set by arguments to
\code{\link{clusterD}}.}

\item{beta}{value between 0 and 1 to decide how stable clustership membership
has to be before 'finding' and removing the cluster.}

\item{top.can}{only the top.can clusters from \code{\link{clusterD}} (ranked
by 'orderBy' argument given to \code{\link{clusterD}}) will be compared
pairwise for stability. Making this very big will effectively remove this
parameter and all pairwise comparisons of all clusters found will be
considered. This might result in smaller clusters being found. Current
default is fairly large, so probably will have little effect.}

\item{remain.n}{when only this number of samples are left (i.e. not yet
clustered) then algorithm will stop.}

\item{k.min}{each iteration of sequential detection of clustering will
decrease the beginning K of subsampling, but not lower than k.min.}

\item{k.max}{algorithm will stop if K in iteration is increased beyond this
point.}

\item{verbose}{whether the algorithm should print out information as to its
progress.}

\item{subsampleArgs}{list of arguments to be passed to
\code{\link{subsampleClustering}}.}

\item{clusterDArgs}{list of arguments to be passed to
\code{\link{clusterD}}(which can include arguments to be passed to
\code{\link{cluster01}} or \code{\link{clusterK}}).}
}
\value{
A list with values
\itemize{

\item{\code{clustering}}{ a vector of length equal to nrows(x) giving the
integer-valued cluster ids for each sample. The integer values are assigned
in the order that the clusters were found. "-1" indicates the sample was not
clustered.}

\item{\code{clusterInfo}}{ if clusters were successfully found, a matrix of
information regarding the algorithm behavior for each cluster (the starting
and stopping K for each cluster, and the number of iterations for each
cluster).}

\item{\code{whyStop}}{ a character string explaining what triggered the
algorithm to stop.}
}
}
\description{
Given a data matrix, this function will call clustering
routines, and sequentially remove best clusters, and iterate to find
clusters.
}
\details{
This code is adapted from the code of the tightClust
 package of Tseng and Wong

Each iteration of the algorithm will cluster the current set of
  samples. Depending on the method, the number of clusters resulting from
  \code{\link{clusterD}} may not be equal to the K used in the clustering of
  the (subsampled) data. The resulting clusters will then be compared to
  clusters found in the previous iteration that set the subsampling
  clustering to K-1. For computational (and other?) convenience, only the
  first top.can clusters of each iteration will be compared to the first
  top.can clusters of previous iteration for similarity (where top.can
  currently refers to ordering by size, so first top.can largest clusters).

If there is a cluster in the current iteration that has overlap
  similarity > beta to a cluster in the previous iteration, then the cluster
  with the largest such similarity will be identified as a 'final' cluster
  and the samples in it will be removed for future iterations. The algorithm
  will then continue to the next iteration, but without these samples.
  Furthermore, in this case K for the next iteration will NOT be set to K+1,
  but will be reset to kinit-1, where kinit was the first K used after the
  previous 'final' cluster was removed. If kinit-1<k.min, then K will be set
  to k.min.

If there is no cluster of the first top.can in the current iteration
  that has overlap similarity > beta to any in the previous iteration, then
  the algorithm will move to the next iteration (i.e. redo after increasing K
  to K+1).

If there are less than remain.n samples left after finding a cluster
  and removing its samples, the algorithm will stop, as subsampling is deamed
  to no longer be appropriate. If the K has to be increased to beyond k.max
  without finding any pair of clusters with overlap > beta, then the
  algorithm will stop. Any samples not found as part of a 'final' cluster
  after the algorithm stops, will be classified as unclustered (given a value
  of -1)

'subsample' controls what is the D (distance) matrix used for
  clustering at each iteration. If subsample=TRUE, D is given via
  \code{\link{subsampleClustering}} function with k=K (with additional
  arguments passed via subsampleArgs). If subsample=FALSE, D is dist(x), for
  the samples currently considered in the iteration and clusterFunction must
  be of the 'K' type (e.g. "pam", see \code{\link{clusterD}}) or an error
  will be produced. The nsample x nsample matrix D is then clustered via
  \code{\link{clusterD}} to find clusters. The option 'clusterFunction' is
  passed to the argument 'clusterFunction' of \code{\link{clusterD}} to
  control what method is used to cluster D.

If clusterFunction is of type 'K' (e.g. "pam", see
  \code{\link{clusterD}}) the 'k' argument of \code{\link{clusterK}} called
  by \code{\link{clusterD}} is set to the current iteration of K by the
  sequential iteration, so setting 'k=' in the list given to clusterDArgs
  will not do anything and will produce a warning to that effect.

Similarly, the current K of the iteration also determines the 'k'
  argument passed to \code{\link{subsampleClustering}}  so setting 'k=' in
  the list given to the subsampleArgs will not do anything and will produce a
  warning to that effect.

If subsample=FALSE and 'findBestK=FALSE' is passed to clusterDArgs,
  then each iteration will run the clustering given by clusterFunction on
  dist(x) iterating over k. However, if subsample=FALSE, you should not set
  'findBestK=TRUE' (otherwise clustering dist(x) will be essentially the same
  for iterating over different k and there is no method implemented to change
  the choice of how to remove a cluster other than similarity as you change
  k); an error message will be given if this combination of options are set.

However, if clusterFunction="pam" (or is of type 'K') and
  subsample=TRUE passing either 'findBestK=TRUE' or 'findBestK=FALSE' will
  function as expected. In particular, the iteration over K will set the
  number of clusters for clustering of each subsample. If findBestK=FALSE,
  that same K will be used for clustering of DMat. If findBestK=TRUE, then
  \code{\link{clusterD}} will search for best k; note that the default
  'kRange' over which \code{\link{clusterD}} searches when findBestK=TRUE
  depends on the input value of 'k' (you can change this to a fixed set of
  values by setting 'kRange' explicitly in the clusterDArgs list).
}
\examples{
\dontrun{
data(simData)

set.seed(12908)

clustSeqHier <- seqCluster(t(simData), k0=5, subsample=TRUE,
clusterFunction="hierarchical01", beta=0.8, subsampleArgs=list(resamp.n=100,
samp.p=0.7, clusterFunction="kmeans", clusterArgs=list(nstart=10)),
clusterDArgs=list(minSize=5))
}
}
\references{
Tseng and Wong (2005), "Tight Clustering: A Resampling-Based
  Approach for Identifying Stable and Tight Patterns in Data", Biometrics,
  61:10-16.
}
\seealso{
tight.clust
}
