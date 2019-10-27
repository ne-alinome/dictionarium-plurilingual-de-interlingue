\ mdf.fs
\
\ This file is part of project _Dictionarium de Interlingue_
\
\ by Marcos Cruz (programandala.net) http://ne.alinome.net
\
\ This program is written in Forth (http//forth-standard.org) with
\ Gforth (http://gnu.org/software/gforth).
\
\ Description: This program parses the temporary sorted file created
\ by Makefile, which contains the MDF markup of all languages (a term
\ and its translation on every line) and converts it into a proper MDF
\ file, sending the result to standard output,
\
\ Last modified 201910271457

\ ==============================================================

80 constant /term
  \ Max length of a term, in bytes.

create term /term allot
  \ Buffer to store the current term.

term /term erase
  \ Erase the buffer.

: term! ( ca len -- ) term place ;
  \ Save string _ca len_ into the term buffer.

: term@ ( -- ca len ) term count ;
  \ Fetch string _ca len_ from the term buffer.

: same-term? ( ca len -- f ) term@ str= ;
  \ Is term _ca len_ the same one already stored in the term buffer?

: backwards ( -- ) -1 >in +! ;
  \ Decrease the contents of `>in` to make sure the input buffer
  \ includes the character "\", which was parsed and discarded by
  \ `parse-term`, and which is part of the MDF translation mark.

: parse-term ( "ccc<\>" -- ca len ) '\' parse backwards ;
  \ Parse a term "ccc" and return it as string _ca len_, without trailing
  \ spaces.

: new-term ( ca len -- ) 2dup term! cr ." \lx " type cr ;
  \ Save the term contained in string _ca len_ into the buffer
  \ and display it as an MDF field.

: \lx ( "ccc<\>" -- )
  parse-term 2dup same-term? if 2drop else new-term then ;
  \ Parse a term "ccc". If it's new, print it, including its MDF mark.
  \ Otherwise discard it.

: discard-comment ( "ccc<eol>" -- ) 0 parse 2drop ;
  \ Parse and discard the final field of the line, which is an
  \ internal comment.

: translation ( ca len "ccc<|>" -- )
  ." \g" type space '|' parse type cr discard-comment ;
  \ Parse translation "ccc" of the current term and print it as an MDF
  \ field corresponding to the ISO language code identified by string
  \ _ca len_. The discard the next field, which is a comment.

: \gcs ( "ccc" -- ) s" cs" translation ;
  \ Czech translation mark: parse the translation and print it as an
  \ MDF field on a new line.

: \gde ( "ccc" -- ) s" de" translation ;
  \ German translation mark: parse the translation and print it as an
  \ MDF field on a new line.

: \geo ( "ccc" -- ) s" eo" translation ;
  \ Esperanto translation mark: parse the translation and print it as
  \ an MDF field on a new line.

\ ==============================================================
\ Change log

\ 2019-10-27: Start.
