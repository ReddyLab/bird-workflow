cwlVersion: v1.2
class: CommandLineTool
baseCommand: gzip

requirements:
  InlineJavascriptRequirement: {}

stdout: $(inputs.name + "_mpileups.txt.gz")

inputs:
  file:
    type: stdin
  name:
    type: string
    inputBinding: null # not used for input
outputs:
  compressed_filtered_pileup:
    type: stdout
