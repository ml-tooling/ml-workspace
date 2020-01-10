from time import strftime
import os

def configure_logging(c):
    folder = os.environ('LOGS_PATH') or '/logs'
    logfilename = strftime('ipython_log_%Y-%m-%d')+".py"
    logfilepath = "/%s" % (folder,logfilename)

    c.LoggingMagics.quiet = True
    c.TerminalInteractiveShell.logappend = logfilepath
    c.TerminalInteractiveShell.logstart = True

c = get_config()

# Make matplotlib output in Jupyter notebooks display correctly
c.IPKernelApp.matplotlib = 'inline'

configure_logging(c)