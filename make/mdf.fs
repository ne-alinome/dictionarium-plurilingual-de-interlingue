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
\ by Makefile, which contains the dictionary data in all languages (a
\ term and its translation on every line) and converts it into an
\ MDF file, sending the result to standard output,
\
\ Last modified 201910271605

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

: new-term ( ca len -- ) 2dup term! cr ." \lx " type cr ;
  \ Save the term contained in string _ca len_ into the buffer
  \ and display it as an MDF field.

: term{ ( "ccc<}>" -- )
  '}' parse 2dup same-term? if 2drop else new-term then ;
  \ Parse a term "ccc", delimited by "}". If it's new, print it,
  \ including its MDF mark.  Otherwise discard it.

: translation ( ca len "ccc<}>" -- )
  ." \g" type space '}' parse type cr ;
  \ Parse translation "ccc" of the current term and print it as an MDF
  \ field corresponding to the ISO language code identified by string
  \ _ca len_.

: cs{ ( "ccc<}>" -- ) s" cs" translation ;
  \ Parse the Czech translation, delimited by "}" and print it as an
  \ MDF field on a new line.

: de{ ( "ccc<}>" -- ) s" de" translation ;
  \ Parse the German translation, delimited by "}" and print it as an
  \ MDF field on a new line.

: eo{ ( "ccc<}>" -- ) s" eo" translation ;
  \ Parse the Esperanto translation, delimited by "}" and print it as
  \ an MDF field on a new line.

\ ==============================================================
\ Change log

\ 2019-10-27: Start.
