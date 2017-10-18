# poolhostPicks
For those unfortunate enough to have a football pick'em pool on poolhost, this will grab the raw table data for the weeks picks.

To use:

`./poolhost -u <username> -p <password> -id <pool id> [-out=<outputfile>]`

If you don't set an output file it'll just make `picks.xls` which might be an xls
or it might be an HTML table.  Poolhost is consistent like that.
