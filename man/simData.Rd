% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataCreation.R
\docType{data}
\name{simData}
\alias{simData}
\alias{simCount}
\alias{trueCluster}
\title{Simulated data for running examples}
\format{Three objects are loaded, two data frame(s) of simulated data each
  with 300 samples/columns and 153 variables/rows, and a vector of length 300
  with the true cluster assignments.}
\description{
Simulated data for running examples
}
\details{
\code{simData} is simulated normal data of 300 observations with 51
  relevant variables and the rest of the variables being noise, with
  observations being in one of 3 groups. \code{simCount} is simulated count
  data of the same dimensions. \code{trueCluster} gives the true cluster
  identifications of the samples. The true clusters are each of size 100 and
  are in order in the columns of the data.frames.
}
\examples{
#code used to create data:
nvar<-51 #multiple of 3
n<-100
x<-cbind(matrix(rnorm(n*nvar,mean=5),nrow=nvar),
 matrix(rnorm(n*nvar,mean=-5),nrow=nvar),
          matrix(rnorm(n*nvar,mean=0),nrow=nvar))
#make some of them flipped effects (better for testing if both sig under/over
#expressed variables)
geneGroup<-sample(rep(1:3,each=floor(nvar/3)))
gpIndex<-list(1:n,(n+1):(n*2),(2*n+1):(n*3))
x[geneGroup==1,]<-x[geneGroup==1,unlist(gpIndex[c(3,1,2)])]
x[geneGroup==2,]<-x[geneGroup==2,unlist(gpIndex[c(2,3,1)])]

#add in differences in variable means
smp<-sample(1:nrow(x),10)
x[smp,]<-x[smp,]+10

#make different signal y
y<-cbind(matrix(rnorm(n*nvar,mean=1),nrow=nvar),
         matrix(rnorm(n*nvar,mean=-1),nrow=nvar),
         matrix(rnorm(n*nvar,mean=0),nrow=nvar))
y<-y[,sample(1:ncol(y))]+ matrix(rnorm(3*n*nvar,sd=3),nrow=nvar)

#add together the two signals
simData<-x+y

#add pure noise variables
simData<-rbind(simData,matrix(rnorm(3*n*nvar,mean=10),nrow=nvar),
               matrix(rnorm(3*n*nvar,mean=5),nrow=nvar))
#make count data
countMean<-exp(simData/2)
simCount<-matrix(rpois(n=length(as.vector(countMean)), lambda
=as.vector(countMean)+.1),nrow=nrow(countMean),ncol=ncol(countMean))
#labels for the truth
trueCluster<-rep(c(1:3),each=n)
#save(list=c("simCount","simData","trueCluster"),file="data/simData.rda")
}
\author{
Elizabeth Purdom \email{epurdom@stat.berkeley.edu}
}
\keyword{data}
