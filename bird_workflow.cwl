cwlVersion: v1.2
class: Workflow

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  names: string[]
  alignment_sets: File[]
  mpileup_depth: int
  genome_file: File
  locations: File

outputs:
  pileup_out:
    type: File[]
    outputSource: mpileups/compressed_filtered_pileup

steps:
  mpileups:
    run: 01_mpileups/pileups_workflow.cwl
    scatter:
      - name
      - alignments
    scatterMethod: dotproduct
    in:
      name: names
      mpileup_depth: mpileup_depth
      genome_file: genome_file
      locations: locations
      alignments: alignment_sets
    out: [compressed_filtered_pileup]
