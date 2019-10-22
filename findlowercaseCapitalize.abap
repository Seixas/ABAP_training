data:
  MATCHES type MATCH_RESULT_TAB,
  MATCH   type MATCH_RESULT.

TRANSLATE item-descricao to lower case.

find all occurrences of regex '\<[[:lower:]]' in item-descricao results MATCHES.
loop at MATCHES into MATCH.
  translate item-descricao+MATCH-OFFSET(1) to upper case.
endloop.
