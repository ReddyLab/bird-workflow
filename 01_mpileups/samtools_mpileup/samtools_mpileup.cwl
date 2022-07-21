cwlVersion: v1.2
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: dukegcb/samtools:1.3

requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.genome_file)

stdout: pileup.txt

baseCommand: samtools
arguments: ['mpileup']
inputs:
  depth:
    type: int
    inputBinding:
      position: 2
      prefix: -d
  genome_file:
    type: File
    secondaryFiles:
      - .fai
    inputBinding:
      position: 3
      prefix: -f
  locations:
    type: File
    inputBinding:
      position: 4
      prefix: -l
  alignments:
    type: File
    inputBinding:
      position: 5
outputs:
  pileups:
    type: stdout
