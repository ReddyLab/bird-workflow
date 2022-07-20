cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  replicate_name: string
  filtered_pileup: File

outputs:
  parsed_filtered_pileup:
    type: File
    outputSource: parse_pileups/parsed_filtered_pileup

steps:
  parse_pileups:
    run: parse_pileup/parse_pileup.cwl
    in:
      filtered_pileup: filtered_pileup
      replicate_name: replicate_name
    out: [parsed_filtered_pileup]
