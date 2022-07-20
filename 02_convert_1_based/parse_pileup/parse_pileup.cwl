cwlVersion: v1.2
class: CommandLineTool

requirements:
  InitialWorkDirRequirement:
      listing:
      - entryname: parse-pileup-no-vcf.py
        entry:
          $include: parse-pileup-no-vcf.py
  InlineJavascriptRequirement: {}

stdout: $(inputs.replicate_name + "_parsed_mpileups.txt")

baseCommand: python
arguments: ['parse-pileup-no-vcf.py']
inputs:
  filtered_pileup:
    type: stdin
  replicate_name:
    type: string
    inputBinding: null # not used for input
outputs:
  parsed_filtered_pileup:
    type: stdout
