cwlVersion: v1.2
class: CommandLineTool

doc: |
  Run BIRD on data

hints:
  DockerRequirement:
    dockerPull: ghcr.io/reddylab/bird-workflow-bird:main

requirements:
  InlineJavascriptRequirement: {}

stdout: $("sczps_no_peaks_BIRD_output_" + inputs.number.toString().padStart(4, "0") + ".txt")

baseCommand: python
arguments: ['/bird/bird.py', '/bird/BIRD']

inputs:
  name:
    type: string
    inputBinding: null
  number:
    type: int
    inputBinding: null
  start:
    type: int
    inputBinding: null
  end:
    type: int
    inputBinding: null
  min_effect:
    type: float
    inputBinding:
      position: 3
  input_file:
    type: File
    inputBinding:
      position: 4
  output_file:
    type: string
    inputBinding:
      position: 5
      valueFrom: $(inputs.name + "_stan_" + inputs.number.toString().padStart(4, "0") + ".txt")
  mcmc_sample_count:
    type: int
    inputBinding:
      position: 6
  range:
    type: string
    inputBinding:
      position: 7
      valueFrom: $(inputs.start.toString() + "-" + inputs.end.toString())

outputs:
  logged_output:
    type: stdout
  stan_output:
    type: File
    outputBinding:
      glob: $(inputs.name + "_stan_" + inputs.number.toString().padStart(4, "0") + ".txt")
