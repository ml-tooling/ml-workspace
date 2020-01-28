define(['base/js/namespace', 'jquery', 'base/js/dialog', 'base/js/utils', 'require', './tooling-shared-components'], function (Jupyter, $, dialog, utils, require, sharedComponents) {

    // -------- GLOBAL VARIABLES -----------------------
    var basePathRegex = "^(\/.+?)\/(tree|notebooks|edit|terminals)";
    var basePath = (window.location.pathname.match(basePathRegex) == null) ? "" : (window.location.pathname.match(basePathRegex)[1] + '/');
    if (!basePath) {
        basePath = "/"
    }

    var dir = window.document.body.dataset.notebookPath;
    var dirname = '/' + dir

    // ----------- HANDLER -------------------------------

    var components = require('./tooling-shared-components');
    var components = new sharedComponents();

    function accessPortDialog() {
        var div = $('<div/>');
        var form = $('<form/>');
        div.append('<label style="width: 50px">Port: </label><input type="number" id="port-input" style="width: 200px" min="1" max="65535"><br>')
        div.append('<br><label style="width: 120px">Get shareable link: </label><input type="checkbox" id="shareable-checkbox">')
        form.appendTo(div);
        return div;
    }

    function sshInstructionDialog(setup_command) {
        // Please check our documentation on information on what you can do with the workspace
        var div = $('<div/>');
        div.append('<p>SSH provides a powerful set of features that enables you to be more productive with your development tasks as documented <a target="_blank" href="https://github.com/ml-tooling/ml-workspace#ssh-access">here</a>. To setup a secure and passwordless SSH connection to this workspace, please execute: </p>');
        div.append('<br>');
        div.append('<textarea readonly="true" style="width: 100%; min-height: 25px; height: 45px" id="ssh-setup-command">' + setup_command + '</textarea>');
        div.append('<br>');
        div.append('<div style="font-size: 11px; color: #909090;">During the setup process, you will be asked for input, e.g to provide a name for the connection. You can also download, copy and run this script to any other machine to setup an SSH connection to this workspace. This scripts only runs on Mac and Linux, Windows is currently not supported.</div>');
        return div
    }

    function installToolDialog(installers) {
        // Please check our documentation on information on what you can do with the workspace
        var div = $('<div/>');
        div.append('<p>The workspace contains a collection of installer scripts for many commonly used development tools or libraries.</p>');
        div.append('<p>1. Please select a tool for further installation instructions:</p>');
        div.append('<br>');

        installer_options = '<option disabled selected>Choose Tool Installer</option>'
        for (var i in installers) {
            var installer = installers[i];
            installer_options += '<option value="' + installer["command"] +  '">' + installer["name"] + '</option>'
        }

        div.append('<select class="form-control" id="install-tool-selection" style="width: 100%; margin-left: 0px;" onchange="(function(e){document.getElementById(\'install-command\').value = e.target.value})(event)">' + installer_options +'</select>');
        div.append('<br>');
        div.append('<p>2. Run the following command within a workspace terminal to install and start the tool:</p>');
        div.append('<br>');
        div.append('<input readonly="true" style="width: 100%; height: 35px; padding: 7px;" id="install-command" value="">');
        return div
    }

    https: //github.com/ml-tooling/ml-workspace#ssh-access
        function load_ipython_extension() {
            // log to console
            console.info('Loaded Jupyter extension: Juypter Tooling')

            components.getToolingList(function (tools) {
                tools_menu_items = '';
                for (var i in tools) {
                    var tool = tools[i];
                    if (tool["url_path"]) {
                        // Add base path to url
                        tool["url_path"] = basePath + tool["url_path"].replace(/^\//g, "")
                        tools_menu_items += '<li> <a id="' + tool["id"] + '" role="menuitem" tabindex="-1" target="_blank" href="' + tool["url_path"] + '">' + tool["name"] + '<span style="display: block; color: #gray; padding: initial; font-size: 12px;">' + tool["description"] + '</span></a> </li>'
                    } else {
                        tools_menu_items += '<li> <a id="' + tool["id"] + '" role="menuitem" tabindex="-1" href="#">' + tool["name"] + '<span style="display: block; color: #gray; padding: initial; font-size: 12px;">' + tool["description"] + '</span></a> </li>'
                    }
                }

                tools_dropwdown = '<div id="start-tool-btn" class="btn-group" style="float: right; margin-right: 2px; margin-left: 2px;"> \
                <button class="dropdown-toggle btn btn-default btn-xs" data-toggle="dropdown" style="padding: 5px 10px;" aria-expanded="false"> \
                <span>Open Tool</span> <span class="caret"></span> </button> \
                <ul id="start-tool" class="dropdown-menu" style="right: 0; left: auto;">' + tools_menu_items + ' </ul> </div>';

                $('#header-container').append(tools_dropwdown)

                $('#ssh-access').click(function () {
                    components.getSSHSetupCommand(window.location.origin, function (data) {
                        dialog.modal({
                            body: sshInstructionDialog(String(data)),
                            title: 'Setup SSH access to this workspace',
                            buttons: {
                                'Download Script': {
                                    click: function () {
                                        window.open(basePath + "tooling/ssh/setup-script?origin=" + window.location.origin + "&download=true", '_blank')
                                    }
                                },
                                'Copy to Clipboard': {
                                    class: 'btn-primary',
                                    click: function (event) {
                                        $('#ssh-setup-command').select()
                                        return window.document.execCommand('copy');
                                    }
                                }
                            }
                        })
                    });
                });


                // install and start a tool
                $('#install-tool').click(function () {
                    components.getToolInstallers(function (data) {

                        // Hotkeys are disabled here so the user can interact without unwanted side effects
                        components.enableKeyboardManager(false);
                        // Disable keyboard manager after 1 sec, otherwise its not always diasabled
                        window.setTimeout(function () {
                            components.enableKeyboardManager(false);
                        }, 1000)

                        dialog.modal({
                            body: installToolDialog(data),
                            title: 'Install and start a tool',
                            keyboard_manager: Jupyter.keyboard_manager,
                            sanitize: false,
                            buttons: {
                                'Close': {
                                    click: function () {
                                        components.enableKeyboardManager(true);
                                    }
                                },
                                'Copy & Open Terminal': {
                                    class: "btn-primary",
                                    click: function () {
                                        components.enableKeyboardManager(true);
                                        $('#install-command').select()
                                        window.document.execCommand('copy');

                                        selecteTool = $('#install-tool-selection option:selected').text()
                                        window.open(basePath + "terminals/" + selecteTool.trim().toLowerCase().replace(/\W/g, '_'), '_blank')
                                    }
                                }
                            }
                        })
                    });
                });

                // open a workspace internal port via subpath - through nginx proxy
                $('#access-port-button').click(function () {
                    // Hotkeys are disabled here so the user can interact without unwanted side effects
                    components.enableKeyboardManager(false);
                    // Disable keyboard manager after 1 sec, otherwise its not always diasabled
                    window.setTimeout(function () {
                        components.enableKeyboardManager(false);
                    }, 1000)

                    dialog.modal({
                        body: accessPortDialog(),
                        title: 'Access a workspace internal port',
                        keyboard_manager: Jupyter.keyboard_manager,
                        sanitize: false,
                        buttons: {
                            'Close': {
                                click: function () {
                                    components.enableKeyboardManager(true);
                                }
                            },
                            'Access': {
                                class: "btn-primary",
                                click: function () {
                                    components.enableKeyboardManager(true);
                                    portInput = $('#port-input').val()
                                    if (!portInput) {
                                        alert("Please input a valid port!")
                                    } else {
                                        if ($('#shareable-checkbox').is(":checked")) {
                                            path = basePath + "shared/tools/" + portInput + "/"
                                            components.getShareableToken(path, function (data) {
                                                window.open(path + "?token=" + String(data), '_blank');
                                            });
                                        } else {
                                            window.open(basePath + "tools/" + portInput + "/", '_blank')
                                        }
                                    }
                                }
                            }
                        }
                    })
                });
            });
        }

    return {
        load_ipython_extension: load_ipython_extension
    };
})