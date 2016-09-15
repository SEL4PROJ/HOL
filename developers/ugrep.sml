fun usage_str() =
        "Usage:\n\
        \  " ^ CommandLine.name() ^ " [-q|-v] dir1 dir2 .. dirn\n\n\
        \Recursively grep over dirs looking for non-ASCII characters."

fun warn s = TextIO.output(TextIO.stdErr, s ^ "\n")
fun die s = (warn s; OS.Process.exit OS.Process.failure)
fun succeed s = (print (s^"\n"); OS.Process.exit OS.Process.success)

fun read_cline args =
  case args of
      ["-h"] => succeed (usage_str())
    | ["-?"] => succeed (usage_str())
    | "-q" :: args => (0, args)
    | "-v" :: args => (2, args)
    | _ => (1, args)

fun includes_unicode s =
  let
    fun recurse i =
      if i < 0 then false
      else
        ord (String.sub(s,i)) > 127 orelse recurse (i - 1)
  in
    recurse (size s - 1)
  end


fun checkfile sofar qp fname =
  let
    val istrm = TextIO.openIn fname
    fun recurse linenum sofar =
      case TextIO.inputLine istrm of
          NONE => (TextIO.closeIn istrm; sofar)
        | SOME line =>
          let
            val ss = Substring.full line
            val (p,s) = Substring.position "UOK" ss
          in
            if Substring.size s <> 0 then recurse (linenum + 1) sofar
            else
              if includes_unicode line then
                (if qp then ()
                 else
                   print (fname^":"^Int.toString linenum^":"^line);
                 recurse (linenum + 1) false)
              else recurse (linenum + 1) sofar
          end
  in
    recurse 1 sofar
  end



fun do_dirstream qp dname ds sofar wlist =
  let
    fun recurse sofar dworklist =
      case OS.FileSys.readDir ds of
          NONE => (OS.FileSys.closeDir ds; (sofar, dworklist))
        | SOME fname =>
          let
            val fullp = OS.Path.concat(dname, fname)
          in
            if OS.FileSys.isDir fullp then recurse sofar (fullp::dworklist)
            else
              let
                val {base,ext} = OS.Path.splitBaseExt fname
              in
                if (ext = SOME "sml" orelse ext = SOME "sig") andalso
                   fname <> "selftest.sml" andalso
                   fname <> "EmitTeX.sml" andalso
                   not (String.isSuffix "Theory" base)
                then
                  recurse (checkfile sofar (qp=0) fullp) dworklist
                else
                  recurse sofar dworklist
              end
          end
  in
    recurse sofar wlist
  end
and do_dirs qp sofar wlist =
    case wlist of
        [] => sofar
      | d::res =>
        let
          val ds = OS.FileSys.openDir d
          val _ = if qp > 1 then warn ("Checking "^d) else ()
          val (sofar, wlist) = do_dirstream qp d ds sofar res
        in
          do_dirs qp sofar wlist
        end

fun main() =
  let
    val (qp, args) = read_cline(CommandLine.arguments())
    val _ = not (null args) orelse die (usage_str())
    val result = do_dirs qp true args
  in
    OS.Process.exit (if result then OS.Process.success else OS.Process.failure)
  end


(*
#!/bin/bash

if [ $# -eq 1 ]
then
    if [ $1 = "-h" -o $1 = "-?" ]
    then
        echo "Usage:"
        echo "  $0 dir1 dir2 .. dirn"
        echo
        echo "Recursively grep over dirs looking for non-ASCII characters"
        echo "If no directories given, run in HOL's src directory"
        exit 0
    fi
fi

cmd="grep -R -n -v -E '^[[:print:][:space:]]*$|UOK' --include='*.sml' --exclude='*Theory.sml' --exclude='*Theory.sig' --exclude selftest.sml --exclude EmitTeX.sml"

if [ $# -eq 0 ]
then
    LC_ALL=C eval $cmd $(dirname $0)/../src/
else
    LC_ALL=C eval $cmd "$@"
fi
*)
