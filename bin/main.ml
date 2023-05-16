(*open Lexing
open Parser
open Lexer
open Expr*)

open Codegen

exception InvalidArg of string

(*let ne_args = InvalidArgument "Llvm-c needs at least one argument"*)

let usage_msg = "llvmc <file.sc> ... -o <output>"

let input_file = ref ""
let output_file = ref ""
let bc_only = ref false
let llprod = ref false
let nox = ref false
let clean_after = ref false

let llvm_bc_file = ref ""
let llvm_compiled_file = ref ""
let clean_list = ref []

let set_input_file fname =
    if !input_file <> "" then 
        raise (InvalidArg "input file redef: can only have one input file")
    else
        input_file := fname

let spec_list = [
    ("-o", Arg.Set_string output_file, " Set output file name");
    ("--out", Arg.Set_string output_file, " same as -o");
    ("--bc", Arg.Set bc_only, " Produce LLVM bitcode only");
    ("--ll", Arg.Set llprod, " Produce human readable ll file");
    ("--nox", Arg.Set nox, " Don't produce executable from compiled llvm");
    ("--clean", Arg.Set clean_after, " Delete produced intermediate files");
] |> Arg.align

let gen_ll fname =
    let _ = Sys.command (Printf.sprintf "llvm-dis %s" fname)
    in ()

let compile_llvm fname =
    let _ = Sys.command (Printf.sprintf "llc %s -o %s" fname !llvm_compiled_file)
    in ()

let gen_exe fname =
    let _ = Sys.command (Printf.sprintf "clang -o %s %s" !output_file fname)
    in ()

let gen_cleanlist() =
    if !bc_only then ()
    else if !llprod || !nox then (clean_list := !llvm_bc_file::!clean_list)
    else if (not !nox) then (clean_list := !llvm_bc_file::(!llvm_compiled_file::!clean_list))

let clean() =
    let __clean fname =
        let _ = Sys.command (Printf.sprintf "rm %s" fname)
        in ()
    in List.iter (fun s -> __clean s) !clean_list
    
let parse_args() =
    begin
        Arg.parse spec_list set_input_file usage_msg;
        llvm_bc_file := (!output_file ^ ".bc"); 
        llvm_compiled_file := (!output_file ^ ".s");
        if !clean_after then gen_cleanlist();
    end

let () =
    let _ = parse_args ()
    in let block = open_in !input_file
        |> Lexing.from_channel 
        |> Parser.program Lexer.token
    in begin
        codegen_main block !llvm_bc_file;
        if (!bc_only) then ();
        if (!llprod) then (gen_ll !llvm_bc_file; clean(); exit 0);
        compile_llvm !llvm_bc_file; (if not !nox then gen_exe !llvm_compiled_file); clean()
    end

