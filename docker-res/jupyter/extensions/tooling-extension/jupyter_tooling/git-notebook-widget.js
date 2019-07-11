define(['base/js/namespace', 'jquery', 'base/js/dialog', 'base/js/utils', 'require', './tooling-shared-components'], function (Jupyter, $, dialog, utils, require, sharedComponents) {

    // -------- GLOBAL VARIABLES -----------------------

    var basePathRegex = "^(\/.+)+\/(tree|notebooks|edit|terminals)";
    var basePath = (window.location.pathname.match(basePathRegex) == null) ? "" : (window.location.pathname.match(basePathRegex)[1] + '/');
    if (!basePath) {
        basePath = "/"
    }

    // ----------- HANDLER -------------------------------

    var components = require('./tooling-shared-components');
    var components = new sharedComponents();

    /**
     * Registers the plugin to tornado
     */
    var git_helper = {
        help: 'Open Git Helper.',
        icon: 'fa-git',
        help_index: '',
        handler: function () {
            Jupyter.notebook.save_notebook();
            var notebookPath = '/' + window.document.body.dataset.notebookPath;
            components.openCommitSingleDialog(notebookPath)
        }
    }
    //---------- REGISTER EXTENSION ------------------------
    /**
     * Adds the jupyter extension to the notebook view (including the respective handler)
     */
    function load_ipython_extension() {
        var prefix = 'notebook';
        var action_name = 'commit_push';
        var full_action_name = Jupyter.actions.register(git_helper, action_name, prefix);

        // add button for new action
        Jupyter.toolbar.add_buttons_group([full_action_name])
    }

    //Loads the extension
    return {
        load_ipython_extension: load_ipython_extension
    };
});