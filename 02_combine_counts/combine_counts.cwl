cwlVersion: v1.2
class: Workflow

doc: |
  Combines read counts (generated by the 01_mpileups workflow) from multiple files into one file.

inputs:
  replicates: File[]

outputs:
  merged_counts:
    type: File
    outputSource: combine_counts/merged_counts

steps:
  replicate_split:
    run: replicate_split/replicate_split.cwl
    in:
      replicates: replicates
    out: [input_replicates, output_replicates]
  combine_counts:
    run: combine_counts/combine_counts.cwl
    in:
      input_replicates: replicate_split/input_replicates
      output_replicates: replicate_split/output_replicates
    out: [merged_counts]
