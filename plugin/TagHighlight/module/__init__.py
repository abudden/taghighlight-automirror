from .version import revtag, datetag

revision = revtag.strip('# ').replace('RevTag:: ', '')
date = datetag.strip('# ').replace('Date:: ', '')
