cwlVersion: v1.2
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: alpine:3.16.1

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: count.sh
        entry: |-
          COUNT=`tail -n +2 $1 | wc -l | awk '{print $1}'`
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
