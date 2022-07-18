cwlVersion: v1.2
class: Workflow

inputs:
  mpileup_depth: int
  genome_file: File
  locations: File
  alignments: File
  name: string

outputs:
  compressed_filtered_pileup:
    type: File
    outputSource: gzip/compressed_filtered_pileup

steps:
  samtools:
    run: samtools_mpileup/samtools_mpileup.cwl
    in:
      depth: mpileup_depth
      genome_file: genome_file
      locations: locations
      alignments: alignments
    out: [pileups]
  filter_unknown_ref_base:
    run: filter_unknown_ref_base/filter_unknown_ref_base.cwl
    in:
      text: samtools/pileups
    out: [filtered_pileup_file]
  gzip:
    run: gzip/gzip.cwl
    in:
      file: filter_unknown_ref_base/filtered_pileup_file
      name: name
    out: [compressed_filtered_pileup]
