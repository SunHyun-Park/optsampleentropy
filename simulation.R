# Library -----------------------------------------------------------------
rm(list=ls())
.libPaths( c( .libPaths(), '/storage/home/s/szl562/R/x86_64-redhat-linux-gnu-library/3.5') )
.libPaths( c( .libPaths(), '/storage/home/s/szl562/R/x86_64-redhat-linux-gnu-library/3.6') )
source('Comparison methods.R')

#install.packages('data.table')
#install.packages('caret')
#install.packages('nloptr')
#install.packages('snowfall')

library(data.table)
library(caret)
library(nloptr)
library(snowfall)

# Parameter ---------------------------------------------------------------

args <- as.numeric(commandArgs(trailingOnly = TRUE))

m <- args[1]
C <- args[2]

optim.tol <- 1e-7
optim.iter <- 1e5

# Load data ---------------------------------------------------------------

data <- fread('healthcare-dataset-stroke-data.csv')
nrow(data)
data <- data[,-c(1)]
data <- data[order(data$stroke)]
data <- data[bmi != "N/A"]
data$bmi <- as.numeric(data$bmi)
nrow(data)
data <- data[gender!="Other"] 
nrow(data)
data <- data[smoking_status!="Unknown"] 
#Note: "Unknown" in smoking_status means that the information is unavailable for this patient
nrow(data)
data$gender <- as.factor(data$gender)
data$ever_married <- as.factor(data$ever_married)
data$work_type <- as.factor(data$work_type)
data$Residence_type <- as.factor(data$Residence_type)
data$smoking_status <- as.factor(data$smoking_status) 

# y, s, x
y <- data$stroke
s <- rep(0,length(data$stroke))

dummy <- dummyVars(stroke~., data=data, fullRank=T) 
x <- cbind(1,predict(dummy, data))
mean(y)

# Split pilot -----------------------------------------------

n <- length(y)
set.seed(1)
pilot_idx <- sample(1:n, m)
pilot <- list()
pilot$x <- x[pilot_idx,]
pilot$y <- y[pilot_idx]
pilot$beta <- ftn.mse.beta(pilot$y,pilot$x,rep(1,m),rep(1,m),rep(0,ncol(pilot$x)))$par
pilot$beta2 <- ftn.ce.beta(pilot$y,pilot$x,rep(1,m),rep(1,m),rep(0,ncol(pilot$x)))$par

y <- y[-pilot_idx]
s <- s[-pilot_idx]
x <- x[-pilot_idx,]


n <- length(y)
n0 <- sum(1-s)

# FULL --------------------------------------------------------------------

#model.s <- glm(s~.-1-y,data=data.table(y=y,s=s,x=x),family='binomial')
ps=rep(0, n)

full <- list()
full$beta <- ftn.ce.beta(y,x,rep(1,n),rep(1,n),pilot$beta2)$par
full <- c(full,ftn.summary(y,s,x,ps,full$beta))

# w OPT weights -------------------------------------------------------------

pilot$w <- ftn.piopt.mse(s,x,pilot$beta,C)

# pi OPT weights ------------------------------------------------------------

pilot$pi <- ftn.piopt.ce(s, x, pilot$beta2, C)

# Simulation
ftn.sim <- function(iter) {
  set.seed(iter)
  result <- NULL
  ecount <- 0

  while (is.null(result)) {
    result <- tryCatch({

      dataset <- data.frame(y=y, s=s, x)

      # SRS ------------------------------------------------------------
      w <- rep(C, n0) / n0
      r <- rep(0, n)
      r[sample(1:n0, C)] <- 1

      # MLE under SRS --------------------------------------------------
      srs <- list()
      srs$est <- ftn.mle.beta(y, x, r, pilot$beta2)
      if(srs$est$convergence!=0) stop("srs convergence error")
      srs <- c(srs, ftn.summary(y, s, x, ps, srs$est$par))

      # Minimize MSE under OPT------------------------------------------
      optw <- list()
      optw$w <- pilot$w
      optw$r <- rep(0, n)
      optw$r[which(rbinom(n0, 1, optw$w) == 1)] <- 1
      optw$est <- ftn.mse.beta(y, x, optw$r, optw$w, pilot$beta)
      if(optw$est$convergence!=0) stop("optw convergence error")
      optw <- c(optw, ftn.summary(y, s, x, ps, optw$est$par))

      # Minimize Cross-Entropy Loss under OPT --------------------------
      optpi <- list()
      optpi$pi <- pilot$pi
      optpi$r <- rep(0, n)
      optpi$r[which(rbinom(n0, 1, optpi$pi) == 1)] <- 1
      optpi$est <- ftn.ce.beta(y, x, optpi$r, optpi$pi, pilot$beta2)
      if(optpi$est$convergence!=0) stop("optpi convergence error")
      optpi <- c(optpi, ftn.summary(y, s, x, ps, optpi$est$par))

      # OSCA -----------------------------------------------------------
      osca <- list()
      osca$beta <- ftn.osca(y,s,x,r,rep(0, ncol(x)))
      osca <- c(osca,ftn.summary(y,s,x,ps,osca$beta))

      # Summary --------------------------------------------------------
      list(
        full.p = full$p,  optw.p = optw$p,  optpi.p = optpi$p, osca.p = osca$p, srs.p = srs$p,
        full.mse = full$mse, optw.mse = optw$mse, optpi.mse = optpi$mse, osca.mse = osca$mse, srs.mse = srs$mse,
        # optw.w = optw$w, optpi.pi = optpi$pi, srs.pi = rep(C / n0, n0),
        ecount = ecount
      )
    }, error = function(e) {
      message(paste("An error occurred - Retrying. Error message:", conditionMessage(e)))
      ecount <<- ecount + 1
      return(NULL)
    })
  }

  return(result)
}

# Parallel computing ------------------------------------------------------

sfInit(parallel=TRUE, cpus=32, type="SOCK")
sfExportAll()
result <- sfClusterApplyLB(1:nsim, ftn.sim)
sfStop()

# Output ------------------------------------------------------------------

save.image(file=paste0('result-',m,'-',C,'.RData'))



