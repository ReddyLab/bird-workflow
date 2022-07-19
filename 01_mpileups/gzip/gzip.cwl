cwlVersion: v1.2
class: CommandLineTool

hints:
    DockerRequirement:
      dockerPull: alpine@sha256:06b5d462c92fc39303e6363c65e074559f8d6b1363250027ed5053557e3398c5

requirements:
  InlineJavascriptRequirement: {}

stdout: $(inputs.name + "_mpileups.txt.gz")

baseCommand: gzip
inputs:
  file:
    type: stdin
  name:
    type: string
    inputBinding: null # not used for input
outputs:
  compressed_filtered_pileup:
    type: stdout
