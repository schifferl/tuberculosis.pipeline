FROM schifferl/bioc-release:latest

ARG URL=https://github.com/xianyi/OpenBLAS/archive/refs/tags/v0.3.3.tar.gz
ARG LIB=/usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.8.so
ARG AWS=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

RUN apt-get update\
 && apt-get upgrade -y\
 && wget -O /tmp/OpenBLAS-0.3.3.tar.gz $URL\
 && tar -C /tmp -xf /tmp/OpenBLAS-0.3.3.tar.gz\
 && make -C /tmp/OpenBLAS-0.3.3\
 && make -C /tmp/OpenBLAS-0.3.3 install\
 && rm -rf /tmp/OpenBLAS-0.3.3.tar.gz /tmp/OpenBLAS-0.3.3\
 && ln -snf /opt/OpenBLAS/lib/libopenblas.so $LIB\
 && wget -O /tmp/awscli-exe-linux-x86_64.zip $AWS\
 && unzip /tmp/awscli-exe-linux-x86_64.zip -d /tmp\
 && sh /tmp/aws/install\
 && rm -rf /tmp/awscli-exe-linux-x86_64.zip /tmp/aws\
 && r -e "BiocManager::install(ask = FALSE)"\
 && r -e "BiocManager::install('affy')"\
 && r -e "BiocManager::install('dplyr')"\
 && r -e "BiocManager::install('furrr')"\
 && r -e "BiocManager::install('googledrive')"\
 && r -e "BiocManager::install('googlesheets4')"\
 && r -e "BiocManager::install('limma')"\
 && r -e "BiocManager::install('magrittr')"\
 && r -e "BiocManager::install('oligo')"\
 && r -e "BiocManager::install('purrr')"\
 && r -e "BiocManager::install('readr')"\
 && r -e "BiocManager::install('rentrez')"\
 && r -e "BiocManager::install('rlang')"\
 && r -e "BiocManager::install('snakecase')"\
 && r -e "BiocManager::install('stringr')"\
 && r -e "BiocManager::install('tibble')"\
 && r -e "BiocManager::install('tidyr')"\
 && r -e "BiocManager::install('tidyselect')"\
 && r -e "BiocManager::install('utils')"\
 && r -e "BiocManager::install('xml2')"\
 && r -e "BiocManager::install('httr')"\
 && r -e "BiocManager::install('illuminaio')"\
 && r -e "BiocManager::install('jsonlite')"\
 && r -e "BiocManager::install('makecdfenv')"\
 && r -e "BiocManager::install('pd.clariom.d.human')"\
 && r -e "BiocManager::install('pd.hta.2.0')"\
 && r -e "BiocManager::install('pd.huex.1.0.st.v2')"\
 && r -e "BiocManager::install('pd.hugene.1.0.st.v1')"\
 && r -e "BiocManager::install('pd.hugene.2.1.st')"\
 && r -e "BiocManager::install('usethis')"
