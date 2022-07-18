cwlVersion: v1.2
class: Workflow

inputs:
  sample_pileup: File
  name: string

outputs:
  example_out:
    type: File
    outputSource: gzip/compressed_filtered_pileup

steps:
  filter_unknown_ref_base:
    run: filter_unknown_ref_base/filter_unknown_ref_base.cwl
    in:
      text: sample_pileup
    out: [filtered_pileup_file]
  gzip:
    run: gzip/gzip.cwl
    in:
      file: filter_unknown_ref_base/filtered_pileup_file
      name: name
    out: [compressed_filtered_pileup]