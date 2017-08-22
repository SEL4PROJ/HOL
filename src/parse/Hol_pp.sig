signature Hol_pp =
sig
  type ppstream = Portable.ppstream
  type hol_type = Type.hol_type
  type term     = Term.term
  type thm      = Thm.thm
  type theory   = DB.theory
  type data     = DB.data


  val pp_type        : ppstream -> hol_type -> unit
  val pp_term        : ppstream -> term -> unit
  val pp_thm         : ppstream -> thm -> unit
  val pp_theory      : ppstream -> theory -> unit

  val type_to_string : hol_type -> string
  val term_to_string : term -> string
  val thm_to_string  : thm -> string

  val print_type     : hol_type -> unit
  val print_term     : term -> unit
  val print_thm      : thm -> unit

  val print_theory : string -> unit

  val data_list_to_string : data list -> string
  val print_apropos       : term -> unit
  val print_find          : string -> unit
  val print_match         : string list -> term -> unit

  val print_theory_to_file      : string -> string -> unit
  val print_theory_to_outstream : string -> TextIO.outstream -> unit
  val export_theory_as_docfiles : string -> unit

  val pp_theory_as_html         : PP.ppstream -> string -> unit
  val print_theory_as_html      : string -> string -> unit
  val html_theory               : string -> unit

end
