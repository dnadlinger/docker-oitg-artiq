FROM continuumio/miniconda3:latest

# Install make for running Sphinx documentation builds.
RUN apt-get update && apt-get install make

# Install ARTIQ. The package can't be installed in the root, so create an
# eponymous environment.
RUN conda config --add channels m-labs && \
    conda config --add channels conda-forge && \
    conda config --add channels m-labs/label/dev && \
    conda config --add channels http://10.255.6.4/condapkg
RUN conda create -qy -n artiq nomkl artiq sphinx && conda clean -tipsy

# Activate the environment by default for container users.
RUN echo "source activate artiq" > ~/.bashrc

# Fetch and install OITG.
ENV OITG=644d0311c75b0624c4eebfc9d227c5b067ff3d0e
RUN wget https://github.com/OxfordIonTrapGroup/oitg/archive/${OITG}.tar.gz && \
    tar xf ${OITG}.tar.gz && \
    cd oitg-${OITG} && \
    bash -c ". activate artiq && python setup.py install" && \
    cd .. && \
    rm -rf ${OITG}.tar.gz oitg-${OITG}

# Install formatters/linters for CI checks. Pin a given version so that previously
# passing builds don't suddenly break if some formatting minutiae change. Update
# from time to time.
RUN bash -c ". activate artiq && \
    pip install --no-cache-dir flake8==3.7.7 yapf==0.29.0"

# Install Sphinx ReadTheDocs theme.
RUN bash -c ". activate artiq && \
    pip install --no-cache-dir sphinx_rtd_theme"

ENTRYPOINT []
CMD [ "/bin/bash" ]
