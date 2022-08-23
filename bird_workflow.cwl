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
  replicate_counts:
    type: File
    outputSource: combineCounts/merged_counts

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
  combineCounts:
    run: 02_combine_counts/combine_counts.cwl
    in:
      replicates: mpileups/ref_count_file
    out: [merged_counts]
