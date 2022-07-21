cwlVersion: v1.2
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: alpine:3.16.1

requirements:
  InlineJavascriptRequirement: {}

stdout: $(inputs.replicate_name + "_mpileups.txt")

baseCommand: awk
arguments: ['{if($3!="N" && $3!="n") print $0}']
inputs:
  text:
    type: stdin
  replicate_name:
    type: string
    inputBinding: null
outputs:
  filtered_pileup_file:
    type: stdout
