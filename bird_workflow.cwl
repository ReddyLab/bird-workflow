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
  names:
    type: string[]
    outputSource: birdScatterValues/names
  indexes:
    type: int[]
    outputSource: birdScatterValues/indexes
  starts:
    type: int[]
    outputSource: birdScatterValues/starts
  ends:
    type: int[]
    outputSource: birdScatterValues/ends

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
  birdScatterValues:
    run: 03_bird_scatter_values/bird_scatter_values.cwl
    in:
      merged_counts: combineCounts/merged_counts
    out:
      [names, indexes, starts, ends]
