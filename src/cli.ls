concat  = require \concat-stream
{ zip } = require \prelude-ls
spawn   = (require \child_process).spawn
esl     = require \./index
require! <[ fs path nopt ]>

print-version = ->
  try
    console.log (require \../package.json .version)
    process.exit 0
  catch e
    console.error e
    console.error "Unknown version; error reading or parsing package.json"
    process.exit 1

print-usage = ->
  console.log do
    "Usage: eslc [-h] [-v] [FILE]\n" +
    "  FILE           file to read (stdin if omitted)\n" +
    "  -v, --version  print version, exit\n" +
    "  -h, --help     print usage, exit"

options =
  version : Boolean
  help : Boolean

option-shorthands =
  v : \--version
  h : \--help

parsed-options = nopt do
  options
  option-shorthands
  process.argv

target-path = null

parsed-options.argv.remain
  .for-each ->
    if target-path
      console.error "Too many arguments (expected 0 or 1 files)"
      process.exit 2
    else
      target-path := it

compile-and-show = -> console.log esl it

if target-path
  e, esl-code <- fs.read-file target-path, encoding : \utf8
  if e then throw e
  compile-and-show esl-code
else
  process.stdin .pipe concat compile-and-show
