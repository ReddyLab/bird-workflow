cwlVersion: v1.2
class: CommandLineTool
baseCommand: awk
arguments: ['{if($3!="N" && $3!="n") print $0}']
stdout: known_refs.txt
inputs:
  text:
    type: stdin
outputs:
  filtered_pileup_file:
    type: stdout