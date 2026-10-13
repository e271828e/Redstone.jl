# print blank-line-delimited paragraphs in [lo,hi] matching pat, with line numbers
NR<lo || NR>hi {next}
/^$/ { if (buf ~ pat) printf "%s\n----\n", buf; buf=""; next }
{ buf = buf sprintf("%d: %s\n", NR, $0) }
END { if (buf ~ pat) print buf }
