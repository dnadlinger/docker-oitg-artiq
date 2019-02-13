FROM continuumio/miniconda3:latest
RUN conda config --add channels m-labs && \
    conda config --add channels conda-forge && \
    conda config --add channels m-labs/label/dev
RUN conda create -qy -n artiq nomkl artiq && conda clean -tipsy
ENTRYPOINT []
CMD [ "/bin/bash" ]
