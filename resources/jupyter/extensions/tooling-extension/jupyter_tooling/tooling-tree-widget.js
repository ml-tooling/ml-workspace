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

    //---------- REGISTER EXTENSION ------------------------
    /**
     * Adds the jupyter extension to the tree view (including the respective handler)
     */
    function load_ipython_extension() {
        // log to console
        console.info('Loaded Jupyter extension: Tooling Tree Widget')

        window.document.title = "Workspace Home"

        base_url = utils.get_body_data('base-url')

        btGitButton = '<div id="start-git-btn" style="margin-right: 5px;">' +
            '<button id="gitTreeButton" class="btn btn-default btn-xs" style="padding: 5px 10px;">' +
            '<span>Git</span>' +
            '</button></div>';

        var vsCodeButton = '<button id="vsCodeTreeButton" title="Open VS Code" aria-label="Open VS Code" style="margin-left: 4px;" class="btn btn-default btn-xs"><i style="font-weight: bold;" class="fa-code fa"></i></button>'
        $('#alternate_upload').before(vsCodeButton);

        $("#vsCodeTreeButton").click(function () {
            var tree_dir = "/workspace/" + window.document.body.dataset.notebookPath;
            window.open(basePath + "tools/vscode/?folder=" + encodeURIComponent(tree_dir), '_blank');
        });

        var btGitButtonInTabView = '<button id="gitTreeButton" title="Open Git Helper" aria-label="Open Git Helper" style="margin-left: 4px;" class="btn btn-default btn-xs"><i class="fa-git fa"></i></button>'
        $('#alternate_upload').before(btGitButtonInTabView);

        $('#gitTreeButton').click(function () {
            var tree_dir = '/' + window.document.body.dataset.notebookPath;
            components.getGitInfo(tree_dir, function (data) {

                let ungitPath = data["requestPath"]
                if (data["repoRoot"]) {
                    ungitPath = data["repoRoot"]
                }
                ungitPath = encodeURIComponent(ungitPath)

                let name = data["userName"]
                let email = data["userEmail"]
                if (Boolean(name) == false || Boolean(email) == false) {
                    components.openSettingsDialog(name, email, tree_dir, function (data) {
                        window.open(basePath + "tools/ungit/#/repository?path=" + ungitPath, '_blank');
                    });
                } else {
                    window.open(basePath + "tools/ungit/#/repository?path=" + ungitPath, '_blank');
                }
            });
        });

        // Commit & push file button
        $(".dynamic-buttons:first").append('<button id="#commit-push-button" title="Commit and push file" style="margin-right: 4px;" class="commit-push-button btn btn-default btn-xs">Commit & Push</button>');
        $(".dynamic-buttons:first").append('<button id="#share-data-button" title="Share data" style="margin-right: 4px;" class="share-data-button btn btn-default btn-xs"><i class="fa fa-share-alt"></i></button>');
        $(".dynamic-buttons:first").append('<button id="#vs-code-button" title="Open VS Code" style="margin-right: 4px;" class="vs-code-button btn btn-default btn-xs">VS Code</button>');

        $(".commit-push-button").click(function () {
            components.openCommitSingleDialog(Jupyter.notebook_list.selected[0].path);
        });

        $(".share-data-button").click(function () {
            components.shareData(Jupyter.notebook_list.selected[0].path);
        });

        $(".vs-code-button").click(function () {
            window.open(basePath + "tools/vscode/?folder=/workspace/" + Jupyter.notebook_list.selected[0].path, '_blank');
        });

        var _selection_changed = Jupyter.notebook_list.__proto__._selection_changed;
        Jupyter.notebook_list.__proto__._selection_changed = function () {
            _selection_changed.apply(this);
            selected = this.selected;
            if (selected.length == 1 && selected[0].type !== 'directory') {
                $('.commit-push-button').css('display', 'inline-block');
                $('.share-data-button').css('display', 'inline-block');
                $('.vs-code-button').css('display', 'none');
            } else if (selected.length == 1 && selected[0].type == 'directory') {
                $('.commit-push-button').css('display', 'none');
                $('.share-data-button').css('display', 'inline-block');
                $('.vs-code-button').css('display', 'inline-block');
            } else {
                $('.commit-push-button').css('display', 'none');
                $('.share-data-button').css('display', 'none');
                $('.vs-code-button').css('display', 'none');
            }
        };
        Jupyter.notebook_list._selection_changed();
    }

    // Loads the extension
    return {
        load_ipython_extension: load_ipython_extension
    };
});