(*open Lexing
open Parser
open Lexer
open Expr*)

open Codegen

exception InvalidArgument of string

let ne_args = InvalidArgument "Llvm-c needs at least one argument"

let filename =
    if (Array.length Sys.argv) < 2 then raise ne_args
    else Sys.argv.(1)

let filename_llvm = "out.bc"

let execname = 
    if (Array.length Sys.argv) < 3 then 
        let fname = filename_llvm
            |> Filename.basename
            |> Filename.remove_extension
        in fname
    else Sys.argv.(2)

let llvm_compile fname execname =
    let _ = Sys.command (Printf.sprintf "llc %s -o out.s" fname)
    in let _ = Sys.command ("rm " ^ fname)
    in let _ = Sys.command (Printf.sprintf "clang -o %s out.s" execname)
    in let _ = Sys.command ("rm out.s")
    in ()

let () =
    let block = open_in filename 
        |> Lexing.from_channel 
        |> Parser.program Lexer.token
    in begin
        codegen_main block filename_llvm;
        llvm_compile filename_llvm execname
    end

