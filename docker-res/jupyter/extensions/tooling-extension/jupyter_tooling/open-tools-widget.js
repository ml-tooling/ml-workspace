define(['base/js/namespace', 'base/js/dialog', 'jquery', 'base/js/utils'], function (Jupyter, dialog, $, utils, mc) {

    var basePathRegex = "^(\/.+)+\/(tree|notebooks|edit|terminals)";
    var basePath = (window.location.pathname.match(basePathRegex) == null) ? "" : (window.location.pathname.match(basePathRegex)[1] + '/');
    if (!basePath) {
        basePath = "/"
    }

    var dir = window.document.body.dataset.notebookPath;
    var dirname = '/' + dir

    let tools = [{
            "id": "vnc-link",
            "name": "VNC",
            "url_path": basePath + "tools/vnc/vnc.html?password=vncpassword",
            "description": "Desktop GUI for the workspace"
        },
        {
            "id": "ungit-link",
            "name": "Ungit",
            "url_path": basePath + "tools/ungit/#/repository?path=%2Fworkspace",
            "description": "Interactive Git interface"
        },
        {
            "id": "jupyterlab-link",
            "name": "JupyterLab",
            "url_path": basePath + "lab",
            "description": "Next-gen user interface for Jupyter"
        },
        {
            "id": "vscode-link",
            "name": "VS Code",
            "url_path": basePath + "tools/vscode/",
            "description": "Visual Studio Code webapp"
        },
        {
            "id": "netdata-link",
            "name": "Netdata",
            "url_path": basePath + "tools/netdata/",
            "description": "Monitor hardware resources"
        },
        {
            "id": "glances-link",
            "name": "Glances",
            "url_path": basePath + "tools/glances/",
            "description": "Monitor hardware resources"
        },
        {
            "id": "open-tools-button",
            "name": "Open Port",
            "url_path": "",
            "description": "Access any workspace internal port"
        },
        {
            "id": "ssh-access",
            "name": "SSH",
            "url_path":  "",
            "description": "Setup SSH connection to the workspace"
        }
    ]

    function openPortDialog() {
        var div = $('<div/>');
        var form = $('<form/>');
        div.append('<label style="width: 50px">Port: </label><input type="number" id="port-input" style="width: 200px" min="1" max="65535"><br>')
        form.appendTo(div);
        return div;
    }

    function openPortDialog() {
        var div = $('<div/>');
        var form = $('<form/>');
        div.append('<label style="width: 50px">Port: </label><input type="number" id="port-input" style="width: 200px" min="1" max="65535"><br>')
        form.appendTo(div);
        return div;
    }

    function sshInstructionDialog() {
        // Please check our documentation on information on what you can do with the workspace
        var div = $('<div/>');
        div.append('<p>SSH provides a powerful set of features that enables you to be more productive with your development tasks as documented <a target="_blank" href="https://github.com/ml-tooling/ml-workspace#ssh-access">here</a>. To setup a secure and passwordless SSH connection to this workspace, please execute: </p>');
        div.append('<br>');
        div.append('<textarea readonly="true" style="width: 100%; min-height: 25px; height: 25px" id="ssh-setup-command">/bin/bash ~/Downloads/setup_ssh_' + window.location.hostname.toLowerCase().replace(".", "-") + '-' + window.location.port + '.sh</textarea>');
        div.append('<br>');
        div.append('<div style="font-size: 11px; color: #909090;">This command assumes that the setup script was downloaded into `~/Downloads` folder, please change the path if the script was downloaded to another location. During the setup process, you will be asked for input, e.g to provide a name for the connection. You can also copy and run this script to any other machine to setup an SSH connection to this workspace. This scripts only runs on Mac and Linux, Windows is currently not supported.</div>');
        return div
    }

    https://github.com/ml-tooling/ml-workspace#ssh-access
    function load_ipython_extension() {
        // log to console
        console.info('Loaded Jupyter extension: Juypter Tooling')
        tools_menu_items = '';
        for (var i in tools) {
            var tool = tools[i];
            if (tool["url_path"]) {
                tools_menu_items += '<li> <a id="' + tool["id"] + '" role="menuitem" tabindex="-1" target="_blank" href="' + tool["url_path"] + '">' + tool["name"] + '<span style="display: block; color: #gray; padding: initial; font-size: 12px;">' + tool["description"] + '</span></a> </li>'
            } else {
                tools_menu_items += '<li> <a id="' + tool["id"] + '" role="menuitem" tabindex="-1" href="#">' + tool["name"] + '<span style="display: block; color: #gray; padding: initial; font-size: 12px;">' + tool["description"] + '</span></a> </li>'
            }
        }

        tools_dropwdown = '<div id="start-tool-btn" class="btn-group" style="float: right; margin-right: 2px; margin-left: 2px;"> \
        <button class="dropdown-toggle btn btn-default btn-xs" data-toggle="dropdown" style="padding: 5px 10px;" aria-expanded="false"> \
            <span>Open Tool</span> <span class="caret"></span> </button> \
           <ul id="start-tool" class="dropdown-menu" style="right: 0; left: auto;">' + tools_menu_items + ' </ul> </div>';
        
        $(tools_dropwdown).insertBefore($('#login_widget'));

        $('#ssh-access').click(function () {
            window.open(basePath + "ssh/setup?hostname=" + window.location.hostname + "&port=" + window.location.port, '_blank')

            dialog.modal({
                body: sshInstructionDialog(),
                title: 'Setup SSH access to this workspace',
                buttons: {
                    'Copy to Clipboard': {
                        class: 'btn-primary',
                        click: function(event) {
                            $('#ssh-setup-command').select()
                            return window.document.execCommand('copy');
                        }
                    }
                }
            })
        });

        // open a workspace internal port via subpath - through nginx proxy
        $('#open-tools-button').click(function () {
            dialog.modal({
                body: openPortDialog(),
                title: 'Access a workspace internal port',
                buttons: {
                    'Close': {},
                    'Open': {
                        class: "btn-primary",
                        click: function () {
                            portInput = $('#port-input').val()
                            if (!portInput) {
                                alert("Please input a valid port!")
                            } else {
                                window.open(basePath + "tools/" + portInput + "/", '_blank')
                            }
                        }
                    }
                }
            })
        });
    }

    return {
        load_ipython_extension: load_ipython_extension
    };
})