# Library and Function ----------------------------------------------------

library(pROC)
library(ggplot2)

to.vector <- function(i,comp) unlist(lapply(get(paste0('result',i)), function(x) x[[comp]]))
to.matrix <- function(i,comp) matrix(unlist(lapply(get(paste0('result',i)), function(x) x[[comp]])),nrow=n)
to.list <- function(i,comp) lapply(get(paste0('result',i)), function(x) x[[comp]])

# Load --------------------------------------------------------------------

m <- 300
sizes <- 300

for(i in 1:length(sizes)){
  load(paste0('result-',m,'-',sizes[i],'.RData'))
  assign(paste0('result',i),result)
}

for(i in 1:length(sizes)){
  tmp <- list()
  
  tmp$full.p <- as.data.frame(to.matrix(i,'full.p'))
  tmp$optpi.p <- as.data.frame(to.matrix(i,'optpi.p'))
  tmp$optw.p <- as.data.frame(to.matrix(i,'optw.p'))
  tmp$osca.p <- as.data.frame(to.matrix(i,'osca.p'))
  tmp$srs.p <- as.data.frame(to.matrix(i,'srs.p'))
  
  tmp$full.mse <- to.vector(i,'full.mse')
  tmp$optpi.mse <- to.vector(i,'optpi.mse')
  tmp$optw.mse <- to.vector(i,'optw.mse')
  tmp$osca.mse <- to.vector(i,'osca.mse')
  tmp$srs.mse <- to.vector(i,'srs.mse')

  tmp$ecount <- to.vector(i,'ecount')
  
  assign(paste0('tmp',i),tmp)
}

rm(list=c('result',paste0('result',1:length(sizes))))

# CE ---------------------------------------------------------------------

for(i in 1:length(sizes)){
  tmp <- get(paste0('tmp',i))
  
  tmp$full.trc <- as.data.frame( (1e-10<=tmp$full.p)&(tmp$full.p<=1-1e-10) )
  tmp$optpi.trc  <- as.data.frame( (1e-10<=tmp$optpi.p )&(tmp$optpi.p <=1-1e-10) )
  tmp$optw.trc  <- as.data.frame( (1e-10<=tmp$optw.p )&(tmp$optw.p <=1-1e-10) )
  tmp$osca.trc <- as.data.frame( (1e-10<=tmp$osca.p)&(tmp$osca.p<=1-1e-10) )
  tmp$srs.trc  <- as.data.frame( (1e-10<=tmp$srs.p )&(tmp$srs.p <=1-1e-10) )
  
  tmp$full.ce <- mapply(function(p,trc) -sum((y*log(p)+(1-y)*log(1-p))[trc])*n/sum(trc), tmp$full.p, tmp$full.trc)
  tmp$optpi.ce  <- mapply(function(p,trc) -sum((y*log(p)+(1-y)*log(1-p))[trc])*n/sum(trc), tmp$optpi.p,  tmp$optpi.trc )
  tmp$optw.ce  <- mapply(function(p,trc) -sum((y*log(p)+(1-y)*log(1-p))[trc])*n/sum(trc), tmp$optw.p,  tmp$optw.trc )
  tmp$osca.ce <- mapply(function(p,trc) -sum((y*log(p)+(1-y)*log(1-p))[trc])*n/sum(trc), tmp$osca.p, tmp$osca.trc)
  tmp$srs.ce  <- mapply(function(p,trc) -sum((y*log(p)+(1-y)*log(1-p))[trc])*n/sum(trc), tmp$srs.p,  tmp$srs.trc )
  
  tmp$optpi.ce.nan  <- is.nan(tmp$optpi.ce)
  tmp$optw.ce.nan  <- is.nan(tmp$optw.ce)
  tmp$osca.ce.nan <- is.nan(tmp$osca.ce)
  tmp$srs.ce.nan  <- is.nan(tmp$srs.ce)
  
  assign(paste0('tmp',i),tmp)
}

# TP,TN -------------------------------------------------------------------

for(i in 1:length(sizes)){
  tmp <- get(paste0('tmp',i))
  
  tmp$full.TN <- apply(tmp$full.p, 2, function(p) sum(p<0.5&y==0)/sum(y==0))
  tmp$full.TP <- apply(tmp$full.p, 2, function(p) sum(p>0.5&y==1)/sum(y==1))
  tmp$optpi.TN  <- apply(tmp$optpi.p, 2, function(p) sum(p<0.5&y==0)/sum(y==0))
  tmp$optpi.TP  <- apply(tmp$optpi.p, 2, function(p) sum(p>0.5&y==1)/sum(y==1))
  tmp$optw.TN  <- apply(tmp$optw.p, 2, function(p) sum(p<0.5&y==0)/sum(y==0))
  tmp$optw.TP  <- apply(tmp$optw.p, 2, function(p) sum(p>0.5&y==1)/sum(y==1))
  tmp$osca.TN <- apply(tmp$osca.p, 2, function(p) sum(p<0.5&y==0)/sum(y==0))
  tmp$osca.TP <- apply(tmp$osca.p, 2, function(p) sum(p>0.5&y==1)/sum(y==1))
  tmp$srs.TN  <- apply(tmp$srs.p, 2, function(p) sum(p<0.5&y==0)/sum(y==0))
  tmp$srs.TP  <- apply(tmp$srs.p, 2, function(p) sum(p>0.5&y==1)/sum(y==1))
  
  assign(paste0('tmp',i),tmp)
}

# AUC ---------------------------------------------------------------------

for(i in 1:length(sizes)){
  tmp <- get(paste0('tmp',i))
  
  tmp$full.auc <- apply(tmp$full.p, 2, function(p) roc(y ~ p,direction="<",quiet=T)$auc)
  tmp$optpi.auc  <- apply(tmp$optpi.p, 2, function(p) roc(y ~ p,direction="<",quiet=T)$auc)
  tmp$optw.auc  <- apply(tmp$optw.p, 2, function(p) roc(y ~ p,direction="<",quiet=T)$auc)
  tmp$osca.auc <- apply(tmp$osca.p, 2, function(p) roc(y ~ p,direction="<",quiet=T)$auc)
  tmp$srs.auc  <- apply(tmp$srs.p, 2, function(p) roc(y ~ p,direction="<",quiet=T)$auc)
  
  assign(paste0('tmp',i),tmp)
}

# table -------------------------------------------------------------------

for(i in 1:length(sizes)){
  tmp <- get(paste0('tmp',i))
  
table <- data.frame( 
  CE  = c(mean(tmp$optpi.ce, na.rm=T),
          mean(tmp$optw.ce, na.rm=T),
          mean(tmp$osca.ce, na.rm=T),
          mean(tmp$srs.ce, na.rm=T),
          mean(tmp$full.ce, na.rm=T)), 
  MSE = c(mean(tmp$optpi.mse),
          mean(tmp$optw.mse),
          mean(tmp$osca.mse),
          mean(tmp$srs.mse),
          mean(tmp$full.mse)), 
  TN  = c(mean(tmp$optpi.TN),
          mean(tmp$optw.TN),
          mean(tmp$osca.TN),
          mean(tmp$srs.TN),
          mean(tmp$full.TN)), 
  TP  = c(mean(tmp$optpi.TP),
          mean(tmp$optw.TP),
          mean(tmp$osca.TP),
          mean(tmp$srs.TP),
          mean(tmp$full.TP)), 
  AUC = c(mean(tmp$optpi.auc),
          mean(tmp$optw.auc),
          mean(tmp$osca.auc),
          mean(tmp$srs.auc),
          mean(tmp$full.auc))
)
  rownames(table) <- c('CE','MSE','OSCA','SRS','FULL')
  
  cat('m=',m,
      ' | C=',sizes[i],
      ' | ecount=',sum(tmp$ecount),
      ' | optpi.ce.nan=',sum(tmp$optpi.ce.nan),
      ' | optw.ce.nan=',sum(tmp$optw.ce.nan),
      ' | osca.ce.nan=',sum(tmp$osca.ce.nan),'\n',sep='')
  print(round(table,3))
  cat('\n')
}
