#!/bin/bash

# Until Space - testing IFS for until next space to remove interfaces from /etc/network/interfaces effectively


# sed -i -e '/central.database =/ s/= .*/= new_value/' /path/to/file

# Explanation:

# -i tells sed to save the results to the input file. Without it sed will print the results to stdout.

# /central.database =/ matches lines that contain the string between slashes, i.e. "central.database =".

# The s/OLD/NEW/ part performs a substitution. The OLD string is a regular expression to match and the NEW part is the string to substitute in.

# In regular expressions, .* means "match anything". So = .* matches an equal sign, space, and then anything else afterward.


sed -n '/eth1/,/^$/{/./p}' interfaces
