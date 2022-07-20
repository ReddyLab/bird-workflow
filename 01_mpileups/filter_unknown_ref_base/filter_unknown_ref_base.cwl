cwlVersion: v1.2
class: CommandLineTool

hints:
    DockerRequirement:
      dockerPull: alpine@sha256:06b5d462c92fc39303e6363c65e074559f8d6b1363250027ed5053557e3398c5

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
