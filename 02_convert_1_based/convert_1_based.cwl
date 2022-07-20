cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  replicate_name: string
  compressed_filtered_pileup: File

outputs:
  processed_pileup:
    type: File
    outputSource: parse_pileups/processed_pileup

steps:
  decompress:
    run: decompress/decompress.cwl
    in:
      compressed_filtered_pileup: compressed_filtered_pileup
    out: [filtered_pileup]
  parse_pileups:
    run: parse_pileup/parse_pileup.cwl
    in:
      filtered_pileup: decompress/filtered_pileup
    out: [processed_pileup]
  compress:
    run: compress/compress.cwl
    in:
      file: parse_pileups/processed_pileup
      replicate_name: replicate_name
    out: [compressed_parsed_filtered_pileup]
