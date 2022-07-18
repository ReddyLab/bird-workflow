cwlVersion: v1.2
class: Workflow

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  name_array: string[]
  alignments_array: File[]
  mpileup_depth: int
  genome_file: File
  mpileup_locations: File

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
      name: name_array
      mpileup_depth: mpileup_depth
      genome_file: genome_file
      locations: mpileup_locations
      alignments: alignments_array
    out: [compressed_filtered_pileup]
