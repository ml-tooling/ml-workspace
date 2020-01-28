"""%tensorboard line magic that patches TensorBoard's implementation to make use of Jupyter 
TensorBoard server extension providing built-in proxying.
Use:
    %load_ext tensorboard.notebook
    %tensorboard --logdir /logs
"""

import argparse
import uuid

from IPython.display import display, HTML, Javascript

def _tensorboard_magic(line):
    """Line magic function.
    Makes an AJAX call to the Jupyter TensorBoard server extension and outputs
    an IFrame displaying the TensorBoard instance.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--logdir', default='/workspace/environment/')
    args = parser.parse_args(line.split())
    
    iframe_id = 'tensorboard-' + str(uuid.uuid4())
        
    html = """
<!-- JUPYTER_TENSORBOARD_TEST_MARKER -->
<script>
    fetch(Jupyter.notebook.base_url + 'api/tensorboard', {
        method: 'POST',
        contentType: 'application/json',
        body: JSON.stringify({ 'logdir': '%s' }),
        headers: { 'Content-Type': 'application/json' }
    })
        .then(res => res.json())
        .then(res => {
            const iframe = document.getElementById('%s');
            iframe.src = Jupyter.notebook.base_url + 'tensorboard/' + res.name;
            iframe.style.display = 'block';
        });
</script>
<iframe
    id="%s"
    style="width: 100%%; height: 620px; display: none;"
    frameBorder="0">
</iframe>
""" % (args.logdir, iframe_id, iframe_id)
    
    display(HTML(html))
    
def load_ipython_extension(ipython):
    """IPython extension entry point."""
    ipython.register_magic_function(
        _tensorboard_magic,
        magic_kind='line',
        magic_name='tensorboard',
    )

def _load_ipython_extension(ipython):
    """Load the TensorBoard notebook extension.
    Intended to be called from `%load_ext tensorboard`. Do not invoke this
    directly.
    Args:
      ipython: An `IPython.InteractiveShell` instance.
    """
    load_ipython_extension(ipython)