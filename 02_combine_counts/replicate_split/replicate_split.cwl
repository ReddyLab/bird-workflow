cwlVersion: v1.2
class: ExpressionTool

doc: |
  Groups replicate into input and output replicates

requirements:
  InlineJavascriptRequirement: {}

inputs:
  replicates:
    type: File[]
outputs:
  input_replicates:
    type: File[]
  output_replicates:
    type: File[]

expression: |
  ${ return {
    "input_replicates": inputs.replicates.filter(function(x) { return x.basename.startsWith("Input")}),
    "output_replicates": inputs.replicates.filter(function(x) { return x.basename.startsWith("Output")})
  }}
