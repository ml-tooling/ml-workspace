import os, json
from setuptools import setup
from setuptools.command.install import install

from notebook.nbextensions import install_nbextension
from notebook.services.config import ConfigManager
from jupyter_core.paths import jupyter_config_dir

EXTENSION_NAME = "jupyter_tooling"
HANDLER_NAME = "tooling_handler"

OPEN_TOOLS_WIDGET = "open-tools-widget"
GIT_TREE_WIDGET = "tooling-tree-widget"
GIT_NOTEBOOK_WIDGET = "tooling-notebook-widget"

EXT_DIR = os.path.join(os.path.dirname(__file__), EXTENSION_NAME)

class InstallCommand(install):
    def run(self):
        open_tools_widget_path = EXTENSION_NAME+"/"+OPEN_TOOLS_WIDGET
        git_tree_widget_path = EXTENSION_NAME+"/"+GIT_TREE_WIDGET
        git_notebook_widget_path = EXTENSION_NAME+"/"+GIT_NOTEBOOK_WIDGET

        # Install Python package
        install.run(self)

        # Install JavaScript extensions to ~/.local/jupyter/
        install_nbextension(EXT_DIR, overwrite=True, user=True)

        # Activate the JS extensions on the notebook, tree, and edit screens
        js_cm = ConfigManager()
        js_cm.update('tree', {"load_extensions": {open_tools_widget_path: True}})
        js_cm.update('notebook', {"load_extensions": {open_tools_widget_path: True}})
        js_cm.update('edit', {"load_extensions": {open_tools_widget_path: True}})

        js_cm.update('notebook', {"load_extensions": {git_notebook_widget_path: True}})
        js_cm.update('tree', {"load_extensions": {git_tree_widget_path: True}})

        # Activate the Python server extension
        server_extension_name = EXTENSION_NAME+"."+HANDLER_NAME

        jupyter_config_file = os.path.join(jupyter_config_dir(), "jupyter_notebook_config.json")
        if not os.path.isfile(jupyter_config_file):
            with open(jupyter_config_file, "w") as jsonFile:
                initial_data = {
                    "NotebookApp":{
                        "nbserver_extensions": {},
                        "server_extensions": []
                    }
                }
                json.dump(initial_data, jsonFile, indent=4)

        with open(jupyter_config_file, "r") as jsonFile:
            data = json.load(jsonFile)
            
        if 'server_extensions' not in data['NotebookApp']:
            data['NotebookApp']['server_extensions'] = []
        
        if 'nbserver_extensions' not in data['NotebookApp']:
            data['NotebookApp']['nbserver_extensions'] = {}
            
        if server_extension_name not in data['NotebookApp']['server_extensions']:
            data['NotebookApp']['server_extensions'] += [server_extension_name]
        
        data['NotebookApp']['nbserver_extensions'][server_extension_name] = True

        with open(jupyter_config_file, "w") as jsonFile:
            json.dump(data, jsonFile, indent=4)


setup(
    name='Jupyter-Tooling-Extension',
    version='0.1',
    packages=[EXTENSION_NAME],
    include_package_data=True,
    cmdclass={
        'install': InstallCommand
    },
    install_requires=[
       'GitPython'
    ]
)


