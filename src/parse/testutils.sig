signature testutils =
sig

datatype testresult = datatype Exn.result

val is_result : 'a testresult -> bool

val linewidth : int ref
val really_die : bool ref
val OK : unit -> unit
val die : string -> 'a
val tprint : string -> unit
val tadd : string -> unit
val tpp : string -> unit
val tpp_expected : {testf:string->string,input:string,output:string} -> unit
val standard_tpp_message : string -> string
val unicode_off : ('a -> 'b) -> 'a -> 'b
val raw_backend : ('a -> 'b) -> 'a -> 'b
val convtest : (string * (Term.term -> Thm.thm) * Term.term * Term.term) -> unit
val timed : ('a -> 'b) -> ('b testresult -> unit) -> 'a -> unit
val exncheck : ('a -> unit) -> 'a testresult -> unit
val shouldfail : {testfn: 'a -> 'b, printresult: 'b -> string,
                  printarg : 'a -> string,
                  checkexn: exn -> bool} -> 'a -> 'b testresult

val is_struct_HOL_ERR : string -> exn -> bool
val check_HOL_ERRexn : (string * string * string -> bool) -> exn -> bool
val check_HOL_ERR : (string * string * string -> bool) -> 'a testresult ->
                    bool
val check_result : ('a -> bool) -> ('a testresult -> bool)
val require : ('b testresult -> bool) -> ('a -> 'b) -> 'a -> 'b testresult
val require_msg : ('b testresult -> bool) -> ('b -> string) -> ('a -> 'b) ->
                  'a -> 'b testresult

val bold : string -> string
val boldred : string -> string
val boldgreen : string -> string
val red : string -> string
val dim : string -> string
val clear : string -> string

end
