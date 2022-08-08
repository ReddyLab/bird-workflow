cwlVersion: v1.2
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: ghcr.io/reddylab/bird-workflow-python:main

requirements:
  InitialWorkDirRequirement:
      listing:
      - entryname: ref_counts.py
        entry:
          $include: ref_counts.py
  InlineJavascriptRequirement: {}

stdout: $(inputs.replicate_name + "_ref_counts.txt")

baseCommand: python
arguments: ['ref_counts.py']
inputs:
  parsed_pileup:
    type: stdin
  replicate_name:
    type: string
    inputBinding: null # not used for input
outputs:
  ref_count_file:
    type: stdout
