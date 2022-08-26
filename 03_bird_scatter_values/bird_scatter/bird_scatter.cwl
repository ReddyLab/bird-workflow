cwlVersion: v1.2
class: CommandLineTool

doc: |
  Compute the parameters needed to split the BIRD work up

hints:
  DockerRequirement:
    dockerPull: python:3.9

requirements:
  InitialWorkDirRequirement:
      listing:
      - entryname: bird_scatter.py
        entry:
          $include: bird_scatter.py

baseCommand: python
arguments: ['bird_scatter.py']
inputs:
  bird_counts:
    type: int
    inputBinding:
      position: 2
outputs:
  names:
    type: string[]
  indexes:
    type: int[]
  starts:
    type: int[]
  ends:
    type: int[]
