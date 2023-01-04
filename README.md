# Bookshelf Notebooks

This template can be used to develop data processing notebooks which will be automatically deployed in three varieties:

1. An interactive - jupyterlab - environment, runnable both locally and hosted on the hosted JupyterLab instance
2. A headless processing image, runnable both locally and as a cluster job
3. A service, which can be hosted on the k8s cluster, and accessed via a REST API

## Setting up your bookshelf

1. Add your Python requirements are to the `project.dependencies` section within the `pyproject.toml`.
2. Fill in `notebook.ipynb` with whatever processing you wish to perform.
3. Update your readme to describe what your bookshelf does.

## Releasing a version

Simply "create a release" on github, this will run a set of continious integration (CI) jobs defined in `.github/workflows` to generate the nessacary containers.

To update the versions available via the diamond module system, run the Project General installation jenkins job for the "bookshelf" package;
This will query the GitHub API and catalogue all containers in the DiamondLightSource repository with the nessacary metadata.

## Running the Containers

### Interactive (local)

```
podman run -p 8888:8888 ghcr.io/garryod/bookshelf-template/interactive:latest
```
or
```
module load bookshelf/bookshelf-template/latest
bookshelf-template-interactive
```


### Interactive (hosted)

1.  Go to https://jupyterhub.diamond.ac.uk/hub/home
2.  'Start My Server' with `CONTAINER_IMAGE=ghcr.io/garryod/bookshelf-template/interactive:latest`

### Processing

```
podman run -v $(pwd):/outputs -v $(pwd):/inputs --security-opt=label=type:container_runtime_t ghcr.io/garryod/bookshelf-template/processing:latest
```
or
```
module load bookshelf/bookshelf-template/latest
bookshelf-template-processing
```

### Service (local)

```
podman run -p 8000:8000 ghcr.io/garryod/bookshelf-template/service:latest
```
