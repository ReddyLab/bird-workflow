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
arguments: ['/bird/bird.py', 'BIRD']

# /data/reddylab/bmajoros/STAN/github/BIRD/bird.py \
# /data/reddylab/bmajoros/STAN/github/BIRD/BIRD-1.1 \
# 1.25 \ # min-effect
# count_files/sczps_merged_counts_for_bird_no_header.txt \ # input file
# stan_files/${NAME}_stan_${NUMBER}.txt \ # output file
# 1000 \ # #MCMC-samples
# ${RANGE} \ # firstVariant-lastVariant
# > BIRD_outputs/outputs/sczps_no_peaks_BIRD_output_${NUMBER}.txt


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
