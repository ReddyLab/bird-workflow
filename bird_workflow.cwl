cwlVersion: v1.2
class: Workflow

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  replicate_names: string[]
  alignment_sets: File[]
  mpileup_depth: int
  genome_file:
    type: File
    secondaryFiles:
      - .fai
  locations: File

outputs:
  pileup_out:
    type: File[]
    outputSource: mpileups/ref_count_file

steps:
  mpileups:
    run: 01_mpileups/pileups_workflow.cwl
    scatter:
      - replicate_name
      - alignments
    scatterMethod: dotproduct
    in:
      replicate_name: replicate_names
      mpileup_depth: mpileup_depth
      genome_file: genome_file
      locations: locations
      alignments: alignment_sets
    out: [ref_count_file]
