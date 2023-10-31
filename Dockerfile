FROM ghcr.io/bimberlabinternal/cellmembrane:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN R -e "install.packages('tidyverse')" && \
  R -e "install.packages('cmdstanr', repos = c('https://mc-stan.org/r-packages/', getOption('repos')))" && \
  R -e "install.packages('RcppParallel')" && \
  R -e "install.packages('brms')" 

RUN R -e "library(cmdstanr);library(brms);dir.create('/cmdstan', showWarnings = FALSE);cmdstanr::install_cmdstan(dir='/cmdstan');cmdstanr::set_cmdstan_path(path = list.dirs('/cmdstan')[[2]])"

RUN chmod -R 777 /cmdstan/*
RUN R -e "library(cmdstanr);cpp_options <- list('CXX' = 'clang++','CXXFLAGS+= -march=native',PRECOMPILED_HEADERS = FALSE);rebuild_cmdstan()"
RUN Rscript --vanilla './brms_within_chain_parallelization.R'
