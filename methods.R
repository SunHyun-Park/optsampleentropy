safe_solve <- function(M, rcond_tol = 1e-8) {
  rc <- tryCatch(1/kappa(M), error=function(e) 0)
  if (!is.finite(rc) || rc < rcond_tol) {
    s <- mean(diag(M))
    lam <- rcond_tol * (s + 1e-12)
    M <- M + diag(lam, ncol(M))
  }
  tryCatch(solve(M), error=function(e) matrix(NA, ncol(M), ncol(M)))
}

# Functions ---------------------------------------------------------------

# MSE

ftn.mse <- function(y,x,r,w,beta){
  p <- 1/(1+exp(-c(x%*%beta)))
  mean(r/w*(p-y)^2)
}
ftn.mse.grad <- function(y,x,r,w,beta){
  p <- 1/(1+exp(-c(x%*%beta)))
  pgrad <- x*p*(1-p)
  colMeans(2*r/w*(p-y)*pgrad)
}
ftn.mse.beta <- function(y,x,r,w,start){
  optim(start,
        fn=function(beta) ftn.mse(y,x,r,w,beta),
        gr=function(beta) ftn.mse.grad(y,x,r,w,beta), method="BFGS",
        control=list(reltol=optim.tol,maxit=optim.iter))
}

# w OPT

ftn.piopt.mse <- function(s,x,beta,C){
  n <- length(s)
  n0 <- sum(1-s)

  p <- 1/(1+exp(-c(x%*%beta)))
  pgrad <- x*p*(1-p)
  Ainv <- safe_solve(t(pgrad)%*%pgrad/n)
  const <- p*(1-p)*diag(pgrad%*%Ainv%*%t(pgrad))
  
  w <- nloptr(
    x0=rep(C,n0)/n0,
    eval_f=function(w) sum(const[1:n0]/w)/n0,
    eval_grad_f=function(w) -const[1:n0]/w^2/n0,
    eval_g_eq=function(w) sum(w)-C,
    eval_jac_g_eq=function(w) rep(1,n0),
    lb=rep(0,n0), ub=rep(1,n0),
    opts=list(algorithm='NLOPT_LD_AUGLAG', maxeval=optim.iter, xtol_rel=optim.tol,
              local_opts=list(algorithm='NLOPT_LD_MMA', xtol_rel=optim.tol))
  )$solution
  return(w)
}

# MLE

ftn.logl <- function(y,x,r,beta){
  p <- 1/(1+exp(-c(x%*%beta)))
  -sum(r*(y*log(p)+(1-y)*log(1-p)))
}
ftn.logl.grad <- function(y,x,r,beta){
  p <- 1/(1+exp(-c(x%*%beta)))
  pgrad <- x*p*(1-p)
  -colSums(r*(y/p-(1-y)/(1-p))*pgrad)
}
ftn.mle.beta <- function(y,x,r,start){
  optim(start,
        fn=function(beta) ftn.logl(y,x,r,beta),
        gr=function(beta) ftn.logl.grad(y,x,r,beta), method="BFGS",
        control=list(reltol=optim.tol,maxit=optim.iter))
}

# Cross-Entropy Loss

ftn.ce <- function(y,x,d,pi,beta) {
  p <- 1/(1 + exp(-c(x %*% beta)))
  -mean(d/pi*(y*log(p)+(1-y)*log(1-p)))
}
ftn.ce.grad <- function(y,x,d,pi,beta) {
  p <- 1/(1+exp(-c(x%*%beta)))
  pgrad <- x*p*(1-p)
  -colMeans(d/pi*(y/p-(1-y)/(1-p))*pgrad)
}
ftn.ce.beta <- function(y,x,d,pi,start) {
  optim(
    start,
    fn = function(beta) ftn.ce(y,x,d,pi,beta),
    gr = function(beta) ftn.ce.grad(y,x,d,pi,beta),
    method = "BFGS",
    control = list(reltol = optim.tol, maxit = optim.iter)
  )
}

# pi OPT

ftn.piopt.ce <- function(s, x, beta, C) {
  n <- nrow(x)
  indices_s0 <- which(s == 0)
  indices_s1 <- which(s == 1)
  n0 <- length(indices_s0)

  p <- 1/(1+exp(-c(x%*%beta)))
  pgrad <- x*as.vector(p*(1-p))
  D <- t(pgrad) %*% (pgrad / as.vector(p*(1-p)))/n
  Dinv <-solve(D)
  numerator   <- diag( pgrad %*% Dinv %*% t(pgrad) )
  denominator <- p * (1 - p)
  ptn <- numerator / denominator
  
  ptn_s0 <- ptn[indices_s0]
  
  pi <- nloptr(
    x0 = rep(C, n0) / n0,
    eval_f = function(pi) sum(ptn_s0 / pi) / n0,
    eval_grad_f = function(pi) -ptn_s0 / pi^2 / n0,
    eval_g_eq = function(pi) sum(pi) - C,
    eval_jac_g_eq = function(pi) rep(1, n0),
    lb = rep(0, n0),
    ub = rep(1, n0),
    opts=list(algorithm='NLOPT_LD_AUGLAG', maxeval=optim.iter, xtol_rel=optim.tol,
              local_opts=list(algorithm='NLOPT_LD_MMA', xtol_rel=optim.tol))
  )$solution
  
  pi_opt <- numeric(n)
  pi_opt[indices_s0] <- pi
  pi_opt[indices_s1] <- 1
  
  return(pi_opt)
}

# OSCA

ftn.osca <- function(y,s,x,r,gamma.f){
  n <- nrow(x)

  beta.v <- ftn.mle.beta(y,x,r,pilot$beta2)$par
  gamma.v <- rep(0,ncol(x))

  h1 <- 1
  h0 <- C/sum(1-s)
  w <- h1*s+h0*(1-s)
  p1 <- sum(r/w*s*y)/sum(r/w*y)
  p0 <- sum(r/w*(1-s)*(1-y))/sum(r/w*(1-y))
  const <- log((h1*p1+h0*(1-p1))/(h1*(1-p0)+h0*p0))
  
  py <- 1/(1+exp(-const-c(x%*%beta.v)))
  ps <- rep(0,n)
  
  Hy <- t(x)%*%diag(r*py*(1-py))%*%x/sum(r)
  Gsy <- t(x)%*%diag(r*w*(y-py)*(s-ps))%*%x/sum(r)
  Gs <- t(x)%*%diag(w^2*(s-ps)^2)%*%x/n
  Hs <- t(x)%*%diag(w*ps*(1-ps))%*%x/n

  beta.v-c(safe_solve(Hy)%*%Gsy%*%safe_solve(Gs)%*%Hs%*%(gamma.v-gamma.f))
}

# Summary statistics

ftn.summary <- function(y,s,x,ps,beta){
  p <- 1/(1+exp(-c(x%*%beta)))
  
  mse <- mean((y-p)^2)

  list(p=p, mse=mse)
}
