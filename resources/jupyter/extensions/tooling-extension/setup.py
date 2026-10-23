from setuptools import setup

EXTENSION_NAME = "jupyter_tooling"

# NOTE: this package used to also install classic-Notebook-6 nbextension JS widgets (the "Open
# Tools" launcher icon) via notebook.nbextensions.install_nbextension, and wrote server-extension
# activation directly into NotebookApp.nbserver_extensions - both classic-Notebook-6-only APIs that
# don't exist under Notebook 7 / JupyterLab 4 / Jupyter Server 2.x. That frontend widget is not
# ported here (would need a real JupyterLab 4 federated-extension rewrite). What *is* kept is the
# backend server extension itself (jupyter_tooling.tooling_handler), which registers plain Tornado
# routes including /tooling/ping - nginx's per-request auth check for /tools/* (VS Code, VNC,
# netdata, glances, ungit) depends on this endpoint existing whenever AUTHENTICATE_VIA_JUPYTER is
# enabled, regardless of whether the launcher widget works. It's enabled the modern way via
# `jupyter server extension enable jupyter_tooling.tooling_handler` in the Dockerfile instead of
# hand-writing config here.
setup(
    name="Jupyter-Tooling-Extension",
    version="0.2",
    packages=[EXTENSION_NAME],
    include_package_data=True,
    install_requires=["GitPython"],
)
