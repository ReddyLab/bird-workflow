cwlVersion: v1.2
class: CommandLineTool

requirements:
  InitialWorkDirRequirement:
      listing:
      - entryname: parse-pileup-no-vcf.py
        entry:
          $include: parse-pileup-no-vcf.py

stdout: pileup.txt

baseCommand: python
arguments: ['parse-pileup-no-vcf.py']
inputs:
  filtered_pileup:
    type: stdin
outputs:
  processed_pileup:
    type: stdout
