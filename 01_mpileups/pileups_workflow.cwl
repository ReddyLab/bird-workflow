cwlVersion: v1.2
class: Workflow

inputs:
  mpileup_depth: int
  genome_file:
    type: File
    secondaryFiles:
      - .fai
  locations: File
  alignments: File
  replicate_name: string

outputs:
  ref_count_file:
    type: File
    outputSource: ref_counts/ref_count_file

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
      replicate_name: replicate_name
    out: [filtered_pileup_file]
  parse_pileup:
    run: parse_pileup/parse_pileup.cwl
    in:
      filtered_pileup: filter_unknown_ref_base/filtered_pileup_file
      replicate_name: replicate_name
    out: [parsed_filtered_pileup]
  ref_counts:
    run: ref_counts/ref_counts.cwl
    in:
      parsed_pileup: parse_pileup/parsed_filtered_pileup
      replicate_name: replicate_name
    out: [ref_count_file]
