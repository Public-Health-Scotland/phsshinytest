FROM phsshinytestgolem_base
COPY renv.lock.prod renv.lock
RUN R -e 'options(renv.config.pak.enabled = FALSE);renv::restore()'
COPY phsshinytestgolem_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz",upgrade="never")'
RUN rm /app.tar.gz
EXPOSE 3838
USER rstudio
CMD R -e "options('shiny.port'=3838,shiny.host='0.0.0.0');library(phsshinytestgolem);phsshinytestgolem::run_app()"
