cwlVersion: v1.2
class: CommandLineTool

doc: |
  Groups replicate into input and output replicates

hints:
  DockerRequirement:
    dockerPull: alpine:3.16.1

requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.replicates)

baseCommand: ls  # Basically, do nothing
inputs:
  replicates:
    type: File[]
    inputBinding:
      position: 1
outputs:
  input_replicates:
    type: File[]
    outputBinding:
      glob: "Input*.txt"
  output_replicates:
    type: File[]
    outputBinding:
      glob: "Output*.txt"
