cwlVersion: v1.2
class: CommandLineTool
baseCommand: samtools
arguments: ['mpileup']
stdout: pileup.txt
inputs:
  depth:
    type: int
    inputBinding:
      position: 2
      prefix: -d
  genome_file:
    type: File
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
