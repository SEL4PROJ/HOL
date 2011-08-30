structure Systeml :> Systeml = struct

(* This is the UNIX implementation of the Systeml functionality.  It is the
   very first thing compiled by the HOL build process so it absolutely
   can not depend on any other HOL source code. *)

structure Path =  OS.Path
structure Process = OS.Process
structure FileSys = OS.FileSys

local
  open Process
  fun concat_wspaces munge acc strl =
    case strl of
      [] => concat (List.rev acc)
    | [x] => concat (List.rev (munge x :: acc))
    | (x::xs) => concat_wspaces munge (" " :: munge x :: acc) xs
in

  val unix_meta_chars = [#"'", #"\"", #"|", #" ", #">", #"\t", #"\n", #"<",
                         #"\\", #"#"]
  fun is_meta c = List.exists (fn y => c = y) unix_meta_chars
  fun is_meta_string(s,i) = if i >= size s then false
                            else if is_meta (String.sub(s,i)) then true
                            else is_meta_string(s, i + 1)
  fun unix_trans c = if is_meta c then "\\" ^ str c else str c

  fun protect s = if is_meta_string(s,0) then String.translate unix_trans s
                  else s

  val systeml = system o concat_wspaces protect []


  fun get_first f [] = NONE
    | get_first f (h::t) = case f h of NONE => get_first f t
                                     | x => x


  fun find_my_path () = let
    (* assumes directory hasn't been changed yet *)
    val myname = CommandLine.name()
    val {dir,file} = Path.splitDirFile myname
  in
    if dir = "" then let
        val pathdirs = String.tokens (fn c => c = #":")
                                     (valOf (Process.getEnv "PATH"))
        open FileSys
        fun checkdir d = let
          val f = Path.concat(d,file)
        in
          if access(f, [A_READ, A_EXEC]) then SOME f else NONE
        end
      in
        valOf (get_first checkdir pathdirs)
      end
    else
      Path.mkAbsolute {path = myname, relativeTo = FileSys.getDir()}
  end

  val system_ps = Process.system
  (* see winNT-systeml.sml for an explanation of why what is a synonym under
     unix needs to be slightly different on Windows. *)

  fun xable_string s = s

  fun mk_xable file =
      if Process.isSuccess (systeml ["chmod", "a+x", file]) then file
      else if FileSys.access (file,[FileSys.A_EXEC]) then
          (* if we can execute it, then continue with a warning *)
          (* NB: MoSML docs say FileSys.access uses real uid/gid, not effective uid/gid,
             so this test may be bogus if we are setuid.  This is unlikely(!). *)
          (print ("Non-fatal warning: couldn't set world execute permission on "^file^",\n  but continuing anyway since at least the current user has execute permission.\n");
           file)
      else (print ("unable to set execute permission on "^file^".\n");
            raise Fail "mk_xable")


fun normPath s = Path.toString(Path.fromString s)

fun fullPath slist =
    normPath (List.foldl (fn (p1,p2) => Path.concat(p2,p1))
                         (hd slist) (tl slist))


(* these values are filled in by configure.sml *)
val HOLDIR =
val POLYMLLIBDIR =
val POLY =
val POLY_LDFLAGS =
val POLY_LDFLAGS_STATIC =
val CC =
val OS =

val DEPDIR =
val GNUMAKE =
val DYNLIB =
val version =
val ML_SYSNAME =
val release =

val isUnix = true

fun exec (x as (comm,args)) =
    (* macos execv fails if the calling process is multi-threaded. *)
    (* Can't lift the check out of the function body because of the value
       restriction *)
    if OS <> "macosx" then Posix.Process.exec x
    else OS.Process.exit (systeml (comm::tl args))


val build_log_dir = fullPath [HOLDIR, "tools-poly", "build-logs"]
val build_log_file = fullPath [build_log_dir, "current-build-log"]
val make_log_file = "current-make-log";

  fun emit_hol_script target exe s =
      let val ostrm = TextIO.openOut target
          fun output s = TextIO.output(ostrm, s)
          val script =
            List.map (fn s => protect (fullPath [HOLDIR, "tools-poly", s]))
                     s
      in
        output "#!/bin/sh\n";
        output "# The bare HOL script\n";
        output "# (automatically generated by HOL configuration)\n\n";
        output (String.concat [exe, " ", String.concatWith " " script, "\n"]);
        TextIO.closeOut ostrm;
        mk_xable target
      end;

  fun emit_hol_unquote_script target exe s =
      let val ostrm = TextIO.openOut target
          fun output s = TextIO.output(ostrm, s)
          val qfilter = protect (fullPath [HOLDIR, "bin", "unquote"])
          val script =
            List.map (fn s => protect (fullPath [HOLDIR, "tools-poly", s]))
                     s
      in
        output "#!/bin/sh\n";
        output "# The HOL script (with quote preprocessing)\n";
        output "# (automatically generated by HOL configuration)\n\n";
        output (String.concat [qfilter, " | ", exe, " ",
                               String.concatWith " " script, "\n"]);
        TextIO.closeOut ostrm;
        mk_xable target
      end;
end (* local *)

end; (* struct *)
