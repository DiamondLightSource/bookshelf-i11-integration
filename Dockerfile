ARG PYTHON_VERSION=3.10

FROM python:${PYTHON_VERSION} as interactive

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[interactive]

EXPOSE 8888

LABEL uk.ac.diamond.bookshelf.runlabel="podman run --rm --publish 8888:8888 --security-opt=label=disable IMAGE"

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--allow-root"]

FROM python:${PYTHON_VERSION}-slim as processing

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[processing]

VOLUME /inputs /outputs

LABEL uk.ac.diamond.bookshelf.runlabel="podman run --rm --volume .:/outputs --volume .:/inputs --security-opt=label=disable IMAGE"

ENTRYPOINT ["papermill", "notebook.ipynb", "/outputs/notebook.ipynb", "--parameters", "OUTPUT_PREFIX", "/outputs",  "--parameters", "INPUT_PREFIX", "/inputs"]

FROM python:${PYTHON_VERSION}-slim as service

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[service]

ENV NOTEBOOK_PATH="notebook.ipynb"

EXPOSE 8000

LABEL uk.ac.diamond.bookshelf.runlabel="podman run --rm --publish 8000:8000 --security-opt=label=disable IMAGE"

ENTRYPOINT ["papermill_service"]
