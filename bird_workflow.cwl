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
  bird_output_prefix: string
  min_effect: float
  bird_output_file: string
  mcmc_sample_count: int
  bird_range: string

outputs:
  logged_output:
    type: File[]
    outputSource: bird/logged_output
  bird_output:
    type: File[]
    outputSource: bird/bird_output

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
  bird:
    run: 04_bird/bird.cwl
    scatter:
      - number
      - start
      - end
    scatterMethod: dotproduct
    in:
      name: bird_output_prefix
      number: birdScatterValues/indexes
      start: birdScatterValues/starts
      end: birdScatterValues/ends
      min_effect: min_effect
      input_file: combineCounts/merged_counts
      output_file: bird_output_file
      mcmc_sample_count: mcmc_sample_count
      range: bird_range
    out:
      [logged_output, bird_output]

