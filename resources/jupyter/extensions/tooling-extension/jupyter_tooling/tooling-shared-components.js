define(['base/js/namespace', 'jquery', 'base/js/dialog', 'require', 'exports', 'module'], function (Jupyter, $, dialog, require, exports, module) {

    var basePathRegex = "^(\/.+?)\/(tree|notebooks|edit|terminals)";
    var basePath = (window.location.pathname.match(basePathRegex) == null) ? "" : (window.location.pathname.match(basePathRegex)[1] + '/');
    if (!basePath) {
        basePath = "/"
    }

    class SharedComponents {


        /**
         * @return {String} function which protects the connection agains xsrf attacks. Sets a token into the header which is stored within a cookie (retrieved by the function getCookie('_xsrf')
         */
        ajaxCookieTokenHandling() {
            return {
                beforeSend: function (xhr, settings) {
                    function getCookie(name) {
                        // Does exactly what you think it does.
                        var cookieValue = null;
                        if (document.cookie && document.cookie != '') {
                            var cookies = document.cookie.split(';');
                            for (var i = 0; i < cookies.length; i++) {
                                var cookie = jQuery.trim(cookies[i]);
                                // Does this cookie string begin with the name we want?
                                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                                    break;
                                }
                            }
                        }
                        return cookieValue;
                    }
                    // Don’t send the token to external URLs
                    if (/^https?:/.test(settings.url)) return;
                    // GET requests don’t need the token
                    if (/GET/.test(settings.type)) return;

                    xhr.setRequestHeader('X-XSRF-TOKEN', getCookie('_xsrf'));
                    xhr.setRequestHeader('X-XSRFToken', getCookie('_xsrf'));
                }
            }
        }

        openErrorDialog(errorMsg, okCallback = null) {
            this.enableKeyboardManager(true)
            dialog.modal({
                body: this.errorDialog(errorMsg),
                title: 'An error occurred',
                keyboard_manager: Jupyter.keyboard_manager,
                sanitize: false,
                buttons: {
                    ' Ok ': {
                        class: "btn-primary",
                        click: function () {
                            if (okCallback) {
                                okCallback()
                            }
                        }
                    }
                }
            })
        }

        openGitErrorDialog(errorMsg, repoPath = null) {
            this.enableKeyboardManager(true)
            dialog.modal({
                body: this.gitErrorDialog(errorMsg),
                title: 'An issue with git occurred',
                keyboard_manager: Jupyter.keyboard_manager,
                sanitize: false,
                buttons: {
                    'Close': {},
                    'Open Ungit': {
                        class: "btn-primary",
                        click: function () {
                            let ungitPath = "/workspace";
                            if (Boolean(repoPath)) {
                                ungitPath = repoPath;
                            }

                            window.open(basePath + "tools/ungit/#/repository?path=" + ungitPath, '_blank');
                        }
                    }
                }
            })
        }

        openSettingsDialog(name, email, directory, successCallback) {
            var that = this;

            dialog.modal({
                title: 'Please provide your user info',
                body: this.configDialog(name, email),
                keyboard_manager: Jupyter.keyboard_manager,
                sanitize: false,
                buttons: {
                    'Close': {},
                    'Ok': {
                        class: "btn-primary",
                        click: function () {
                            email = document.getElementById("email").value
                            name = document.getElementById("name").value
                            that.sendUserInfo(directory, name, email, successCallback);
                        }
                    }
                }
            })
        }

        openCommitSingleDialog(filePath) {
            var that = this;


            this.getGitInfo(filePath, function (data) {
                console.log("git infor data:")
                console.log(data)

                let repoPath = data["requestPath"]
                // request path contains the filename -> remove filename from path
                repoPath = repoPath.substring(0, repoPath.lastIndexOf("/"));
                if (data["repoRoot"]) {
                    repoPath = data["repoRoot"]
                }

                let name = data["userName"]
                let email = data["userEmail"]
                if (Boolean(name) == false || Boolean(email) == false) {
                    that.openSettingsDialog(name, email, repoPath, function () {
                        that.openCommitSingleDialog(filePath)
                    });
                    return
                }

                let ungitPath = encodeURIComponent(repoPath)

                if (Boolean(data["repoRoot"]) == false) {
                    that.openGitErrorDialog("This file is not in a valid git repository.", ungitPath);
                } else {
                    // Hotkeys are disabled here so the user can enter a commit message without unwanted side effects
                    that.enableKeyboardManager(false);
                    // Disable keyboard manager after 1 sec, otherwise its not always diasabled
                    window.setTimeout(function () {
                        that.enableKeyboardManager(false);
                    }, 1000)
                    dialog.modal({
                        title: 'Commit and push this notebook',
                        body: that.commitDialogSingle(data),
                        keyboard_manager: Jupyter.keyboard_manager,
                        sanitize: false,
                        buttons: {
                            'Settings': {
                                click: function () {
                                    that.openSettingsDialog(name, email, repoPath, function () {
                                        that.openCommitSingleDialog(filePath)
                                    });
                                }
                            },
                            'Close': {
                                click: function () {
                                    that.enableKeyboardManager(true);
                                }
                            },
                            'Commit & Push': {
                                class: "btn-primary", //btn-outline-success
                                click: function () {
                                    that.enableKeyboardManager(true);
                                    var push_btn = '<div id="notification_pushing" class="notification_widget btn btn-xs navbar-btn info" style="display: inline-block;"><span>Pushing Notebook</span></div>'
                                    // Notebook
                                    $('#notification_area').prepend(push_btn)
                                    // Tree
                                    $('#gitTreeButton').before(push_btn);

                                    let commitMsg = $('#commitmessage').val();
                                    that.commitFile(filePath, commitMsg, ungitPath, function () {
                                        $('#notification_pushing').remove()
                                        var push_btn = '<div id="notification_push" class="notification_widget btn btn-xs navbar-btn success" style="display: inline-block;"><span>Push Successful</span></div>'
                                        // Notebook
                                        $('#notification_area').prepend(push_btn)
                                        // Tree
                                        $('#gitTreeButton').before(push_btn);
                                        window.setTimeout(function () {
                                            $('#notification_push').remove()
                                        }, 7000)
                                    })
                                }
                            }
                        }
                    })
                }
            });
        }

        enableKeyboardManager(enable) {
            if (!Jupyter.keyboard_manager) {
                return
            }

            if (enable) {
                Jupyter.keyboard_manager.enable();
            } else {
                Jupyter.keyboard_manager.disable();
            }
        }

        commitFile(filePath, commitMsg = null, repoPath = null, success_callback = null) {
            var that = this;
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var settings = {
                url: basePath + 'tooling/git/commit',
                processData: false,
                type: "POST",
                data: JSON.stringify({
                    'filePath': filePath,
                    'commitMsg': commitMsg
                }),
                success: function (data) {
                    if (!data) {
                        data = "{}"
                    }

                    success_callback(JSON.parse(data));
                },
                error: function (response) {
                    $('#notification_pushing').remove()
                    let errorMsg = "An unknown error occurred while commiting the file.";
                    if (response && response.responseText) {
                        let data = JSON.parse(response.responseText)
                        if (Boolean(data["error"])) {
                            errorMsg = data["error"];
                        }
                    }
                    that.openGitErrorDialog(errorMsg, repoPath);
                }
            }
            $.ajax(settings)
        }

        /**
         * Sends user information to the server
         * @param {data} contains numerous user information
         */
        sendUserInfo(path, name, email, success_callback) {
            var that = this;
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var settings = {
                url: basePath + 'tooling/git/info?path=' + path,
                processData: false,
                type: "POST",
                data: JSON.stringify({
                    'email': email,
                    'name': name
                }),
                success: function (data) {
                    if (!data) {
                        data = "{}"
                    }

                    success_callback(JSON.parse(data));
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while sending user info.";
                    if (response && response.responseText) {
                        let data = JSON.parse(response.responseText)
                        if (Boolean(data["error"])) {
                            errorMsg = data["error"];
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }

        getGitInfo(path, success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/git/info?path=' + path,
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(JSON.parse(data))
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while getting git info.";
                    if (response && response.responseText) {
                        let data = JSON.parse(response.responseText)
                        if (Boolean(data["error"])) {
                            errorMsg = data["error"];
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }

        getShareableToken(path, success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/token?path=' + path,
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(data)
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while getting auth token.";
                    if (response && response.responseText) {
                        try {
                            let data = JSON.parse(response.responseText)
                            if (Boolean(data["error"])) {
                                errorMsg = data["error"];
                            }
                        } catch (e) {
                            errorMsg = String(response.responseText)
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }

        getToolInstallers(success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/tool-installers',
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(JSON.parse(data))
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while getting list of available tool installers.";
                    if (response && response.responseText) {
                        try {
                            let data = JSON.parse(response.responseText)
                            if (Boolean(data["error"])) {
                                errorMsg = data["error"];
                            }
                        } catch (e) {
                            errorMsg = String(response.responseText)
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }    

        getToolingList(success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/tools',
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(JSON.parse(data))
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while getting list of available tools.";
                    if (response && response.responseText) {
                        try {
                            let data = JSON.parse(response.responseText)
                            if (Boolean(data["error"])) {
                                errorMsg = data["error"];
                            }
                        } catch (e) {
                            errorMsg = String(response.responseText)
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }    

        getSSHSetupCommand(origin_url, success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/ssh/setup-command?origin=' + origin_url,
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(data)
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while getting ssh setup command.";
                    if (response && response.responseText) {
                        try {
                            let data = JSON.parse(response.responseText)
                            if (Boolean(data["error"])) {
                                errorMsg = data["error"];
                            }
                        } catch (e) {
                            errorMsg = String(response.responseText)
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }

        getSharableFileLink(origin_url, path, success_callback) {
            $.ajaxSetup(this.ajaxCookieTokenHandling());
            var that = this;
            var settings = {
                url: basePath + 'tooling/files/link?origin=' + origin_url + "&path=" + path,
                processData: false,
                type: "GET",
                success: function (data) {
                    success_callback(data)
                },
                error: function (response) {
                    let errorMsg = "An unknown error occurred while generating sharable file link.";
                    if (response && response.responseText) {
                        try {
                            let data = JSON.parse(response.responseText)
                            if (Boolean(data["error"])) {
                                errorMsg = data["error"];
                            }
                        } catch (e) {
                            errorMsg = String(response.responseText)
                        }
                    }
                    that.openErrorDialog(errorMsg, null);
                }
            }
            $.ajax(settings)
        }

        shareFileDialog(shareLink) {
            var div = $('<div/>');
            div.append('<p>Anyone with the follwing link can view and download the selected file or folder:</p>');
            div.append('<br>');
            div.append('<textarea readonly="true" style="width: 100%; min-height: 25px; height: 45px" id="sharable-file-link">' + shareLink + '</textarea>');
            div.append('<br>');
            div.append('<div style="font-size: 11px; color: #909090;">Be careful and responsible with whom you share sensitive data. This sharable link will not expire and cannot currently be deactivated.</div>');
            return div
        }

        shareData(path) {
            var that = this;
            that.getSharableFileLink(window.location.origin, path, function (data) {
                dialog.modal({
                    body: that.shareFileDialog(String(data)),
                    title: 'Share data with others',
                    buttons: {
                        'Close': {
                        },
                        'Copy to Clipboard': {
                            class: 'btn-primary',
                            click: function (event) {
                                $('#sharable-file-link').select()
                                return window.document.execCommand('copy');
                            }
                        }
                    }
                })
            });
        }

        /**
         * @param {list} contains email and name
         * @return {string} The html code to configure the git.name and the git.email of the git user
         */
        configDialog(name, email) {
            var div = $('<div/>');
            var form = $('<form/>');
            if (!name) {
                name = ""
            }

            if (!email) {
                email = ""
            }
            div.append('<label style="width: 50px">Name: </label><input type="text" id="name" value="' + name + '" style="width: 200px"><br>');
            div.append('<label style="width: 50px">Email: </label><input type="text" id="email" value="' + email + '" style="width: 200px"><br>');

            form.appendTo(div);
            return div;
        }

        commitDialogSingle(gitInfoData) {
            var div = $('<div/>');
            var form = $('<form id="gitform" />');
            var userEmail = (gitInfoData["userEmail"] == null) ? " " : gitInfoData["userEmail"];
            var userName = (gitInfoData["userName"] == null) ? " " : gitInfoData["userName"];
            var lastCommit = (gitInfoData["lastCommit"] == null) ? " " : gitInfoData["lastCommit"];
            var activeBranch = (gitInfoData["activeBranch"] == null) ? " " : gitInfoData["activeBranch"];
            var repoRoot = (gitInfoData["repoRoot"] == null) ? "/workspace" : gitInfoData["repoRoot"];

            var ungitPath = basePath + "tools/ungit/#/repository?path=" + repoRoot

            div.append('<div style="display: flex;">' +

                '<p style="width: 50%; float:left">' +
                ' Commit message: ' +
                ' <textarea style="resize:none" id="commitmessage" rows="4" cols="40"></textarea>' +
                '</p>' +
                '<p style="font-size:12px; width: 50%; float:right; color:#909090;">' +

                '<a target="_blank" href="' + ungitPath + '" style="padding-right: 5px; float:right; font-size:10px;" >Ungit</a><br>' +
                '<label style="width: 120px">Last Commit:</label>' +
                '<label id="lastCommit">' + lastCommit + '</label><br>' +
                '<label style="width: 120px">Push to Branch: </label>' +
                '<label id="activeBranch">' + activeBranch + '</label><br>' +
                '<label style="width: 120px">Configured email: </label>' +
                '<label id="email">' + userEmail + '</label><br>' +
                '<label style="width: 120px">Configured name: </label>' +
                '<label id="name">' + userName + '</label><br>' +
                '</p>' +
                '</div>'
            )

            form.appendTo(div);
            return div;
        }

        /**
         * @param {list} contains errormessage
         * @return {string} The html code of a error dialog
         */
        errorDialog(errorMsg) {
            var div = $('<div/>');
            // div.append('<p>The following error was encountered:</p>');
            div.append('<p>' + errorMsg + '</p>');
            return div
        }

        gitErrorDialog(errorMsg) {
            var div = $('<div/>');
            div.append('<p>' + errorMsg + '</p><br>');
            div.append('<p>Please try to fix this issue with ungit or the terminal.</p>');
            return div
        }

    };

    module.exports = SharedComponents; // export class in order to create an object of it in another file
});