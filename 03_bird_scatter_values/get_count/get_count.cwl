cwlVersion: v1.2
class: CommandLineTool

doc: |
  Get the number of variants to run BIRD on

hints:
  DockerRequirement:
    dockerPull: alpine:3.16.1

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: count.sh
        entry: |-
          COUNT=`grep -chv -e '^$' $1`  # count the number of non-blank lines
          echo "{\"bird_counts\":$COUNT}" > cwl.output.json

baseCommand: "sh"
arguments: ["count.sh"]
inputs:
  merged_counts:
    type: File
    inputBinding:
      position: 2
outputs:
  bird_counts:
    type: int
