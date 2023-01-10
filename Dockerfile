ARG PYTHON_VERSION=3.10

FROM python:${PYTHON_VERSION} as base

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        ocl-icd-libopencl1

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

FROM python:${PYTHON_VERSION}-slim as base-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        ocl-icd-libopencl1

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

FROM base as interactive

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[interactive]

EXPOSE 8888

CMD ["jupyter-lab", "--ip=0.0.0.0", "--allow-root"]

FROM base-slim as processing

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[processing]

VOLUME /inputs /outputs

ENTRYPOINT ["papermill", "notebook.ipynb", "/outputs/notebook.ipynb", "--parameters", "OUTPUT_PREFIX", "/outputs",  "--parameters", "INPUT_PREFIX", "/inputs"]

FROM base-slim as service

ENV WORKDIR=/environment
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}

RUN pip install --upgrade .[service]

ENV NOTEBOOK_PATH="notebook.ipynb"

EXPOSE 8000

ENTRYPOINT ["papermill_service"]
