cwlVersion: v1.2
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: python:3.9 # Replace with our python docker image (that includes pandas)

requirements:
  InitialWorkDirRequirement:
      listing:
      - entryname: combine_counts.py
        entry:
          $include: combine_counts.py

stdout: merged_counts_for_bird_no_header.txt

baseCommand: python
arguments: ['combine_counts.py']
inputs:
  input_replicates:
    type: File[]
    inputBinding:
      position: 2
      prefix: -i
  output_replicates:
    type: File[]
    inputBinding:
      position: 3
      prefix: -o

outputs:
  merged_counts:
    type: stdout