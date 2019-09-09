define(['base/js/namespace', 'jquery', 'base/js/dialog', 'base/js/utils', 'require', './tooling-shared-components'], function (Jupyter, $, dialog, utils, require, sharedComponents) {

    // -------- GLOBAL VARIABLES -----------------------

    var basePathRegex = "^(\/.+?)\/(tree|notebooks|edit|terminals)";
    var basePath = (window.location.pathname.match(basePathRegex) == null) ? "" : (window.location.pathname.match(basePathRegex)[1] + '/');
    if (!basePath) {
        basePath = "/"
    }

    // ----------- HANDLER -------------------------------

    var components = require('./tooling-shared-components');
    var components = new sharedComponents();

    var git_helper = {
        help: 'Commit and Push Notebook.',
        icon: 'fa-git',
        help_index: '',
        handler: function () {
            Jupyter.notebook.save_notebook();
            var notebookPath = '/' + window.document.body.dataset.notebookPath;
            components.openCommitSingleDialog(notebookPath)
        }
    }

    var share_notebook = {
        help: 'Share Notebook.',
        icon: 'fa-share-alt',
        help_index: '',
        handler: function () {
            Jupyter.notebook.save_notebook();
            var notebookPath = '/' + window.document.body.dataset.notebookPath;
            components.shareData(notebookPath)
        }
    }
    //---------- REGISTER EXTENSION ------------------------
    /**
     * Adds the jupyter extension to the notebook view (including the respective handler)
     */
    function load_ipython_extension() {
        console.info('Loaded Jupyter extension: Tooling Notebook Widget')
        // add button for new action
        Jupyter.toolbar.add_buttons_group([Jupyter.actions.register(git_helper, 'commit_push', 'notebook')])
        Jupyter.toolbar.add_buttons_group([Jupyter.actions.register(share_notebook, 'share_notebook', 'notebook')])
    }

    //Loads the extension
    return {
        load_ipython_extension: load_ipython_extension
    };
});