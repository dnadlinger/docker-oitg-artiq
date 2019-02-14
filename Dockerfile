FROM continuumio/miniconda3:latest

# Install ARTIQ. The package can't be installed in the root, so create an
# eponymous environment.
RUN conda config --add channels m-labs && \
    conda config --add channels conda-forge && \
    conda config --add channels m-labs/label/dev
RUN conda create -qy -n artiq nomkl artiq && conda clean -tipsy

# Activate the environment by default for container users.
RUN echo "source activate artiq" > ~/.bashrc

# Fetch and install OITG.
ENV OITG=933ba037f6354f4b2652592c44f9d74a3be29b30
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
    pip install --no-cache-dir flake8==3.7.5 yapf==0.26.0"

ENTRYPOINT []
CMD [ "/bin/bash" ]
