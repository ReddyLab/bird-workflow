cwlVersion: v1.2
class: Workflow

inputs:
  merged_counts: File

outputs:
  names:
    type: string[]
    outputSource: bird_scatter/names
  indexes:
    type: int[]
    outputSource: bird_scatter/indexes
  starts:
    type: int[]
    outputSource: bird_scatter/starts
  ends:
    type: int[]
    outputSource: bird_scatter/ends

steps:
  get_count:
    run: get_count/get_count.cwl
    in:
      merged_counts: merged_counts
    out: [bird_counts]
  bird_scatter:
    run: bird_scatter/bird_scatter.cwl
    in:
      bird_counts: get_count/bird_counts
    out: [names, indexes, starts, ends]
