FROM continuumio/miniconda3:latest

# Install make for running Sphinx documentation builds, and libGL to be
# able to import Quamash (even though we don't actually use QtGui in the
# tests, it still gets imported).
RUN apt-get update && apt-get install -y libgl1 make

# Install ARTIQ. The package can't be installed in the root, so create an
# eponymous environment. (The repositories end up taking precedence in the
# inverse order as added here, so conda-forge needs to be below the m-labs
# labels to avoid pulling in an old, incompatible version of prettytable.)
RUN conda config --add channels m-labs && \
    conda config --add channels m-labs/label/obsolete && \
    conda config --add channels conda-forge && \
    conda config --add channels http://10.255.6.4/condapkg
RUN conda create -qy -n artiq nomkl artiq-env sphinx && conda clean -tipsy

# Activate the environment by default for container users.
RUN echo "source activate artiq" > ~/.bashrc

# Pin pandas==0.25.3 (which is depended on by statsmodels, which is depended on by oitg),
# as Pandas 1.0+ does not install on Python 3.5 anymore.
RUN bash -c ". activate artiq && \
    pip install --no-cache-dir pandas==0.25.3 statsmodels"

# Fetch and install OITG.
ENV OITG=dfc935a4014e78def056ebd295a0d2f19f6e008c
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
    pip install --no-cache-dir flake8==3.8.3 yapf==0.30.0"

# Install Sphinx ReadTheDocs theme.
RUN bash -c ". activate artiq && \
    pip install --no-cache-dir sphinx_rtd_theme"

ENTRYPOINT []
CMD [ "/bin/bash" ]
