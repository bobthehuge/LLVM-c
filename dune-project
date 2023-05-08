(lang dune 3.6)

(name llvmc)

(generate_opam_files true)

(source
 (github bobthehuge/LLVM-c))

(authors "Daniel Volya" "Nicholas Suhlman")

(maintainers "Henri Weidmann")

;(license LICENSE)

;(documentation https://url/to/documentation)

(using menhir 2.0)

(package
 (name llvmc)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
