# Make matplotlib output in Jupyter notebooks display correctly
c = get_config()

c.IPKernelApp.matplotlib = "inline"
c.TerminalInteractiveShell.history_length = 10000
c.IPythonWidget.buffer_size = 10000

# c.InteractiveShellApp.extensions = ['autoreload']
# c.InteractiveShellApp.exec_lines = ['%autoreload 2', '%pylab']
