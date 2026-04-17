# bird-workflow

A [CWL](https://www.commonwl.org/) workflow for running [BIRD](https://github.com/bmajoros/BIRD) (Bayesian Inference of Regulatory Differences), a statistical tool that uses MCMC sampling to detect allele-specific regulatory activity from paired DNA and RNA read counts.

## Overview

BIRD models allelic imbalance between a DNA input library (measuring allele frequency at the genomic level) and one or more RNA output libraries (measuring allele frequency at the expression level). For each variant site, it estimates an effect size (θ, an odds ratio) and reports a posterior probability of regulatory difference.

This workflow automates the full pipeline from BAM files to BIRD output:

```
BAM files
   │
   ▼
01_mpileups      — samtools mpileup → filter → parse → per-replicate ref/alt counts
   │
   ▼
02_combine_counts — merge all replicates into a single BIRD-format input file
   │
   ▼
03_bird_scatter   — compute scatter indices to parallelise BIRD across variant chunks
   │
   ▼
04_bird           — run BIRD (Stan MCMC) on each chunk, collect results
```

## Requirements

- A CWL runner (e.g. [cwltool](https://github.com/common-workflow-language/cwltool))
- Docker (images are built automatically via GitHub Actions)
- BAM files (indexed) for each DNA and RNA replicate
- A reference genome FASTA (with `.fai` index)
- A positions file listing the variant sites to test

## Workflow inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `replicate_names` | `string[]` | Ordered list of replicate names (DNA inputs first, then RNA outputs) |
| `alignment_sets` | `File[]` | BAM files in the same order as `replicate_names` |
| `mpileup_depth` | `int` | `samtools mpileup` max depth (`0` = unlimited) |
| `genome_file` | `File` | Reference genome FASTA (must have `.fai` sidecar) |
| `locations` | `File` | Tab-delimited positions file for `samtools mpileup -l` |
| `bird_output_prefix` | `string` | Prefix for BIRD output file names |
| `bird_output_file` | `string` | Placeholder (overridden internally per scatter chunk) |
| `min_effect` | `float` | Minimum effect size λ ≥ 1 (e.g. `1.25` = 25 % fold-change) |
| `mcmc_sample_count` | `int` | Number of MCMC samples per variant |
| `bird_range` | `string` | Placeholder (overridden internally per scatter chunk) |

See [sample_bird_workflow.yml](sample_bird_workflow.yml) for a concrete example.

## Running the workflow

```bash
cwltool bird_workflow.cwl sample_bird_workflow.yml
```

## Pipeline steps

### 1. Mpileups (`01_mpileups/`)

For each replicate the sub-workflow:
1. Runs `samtools mpileup` at the requested depth over the positions in `locations`.
2. Filters pileup lines whose reference base is unknown (`N`).
3. Parses the pileup into per-position ref and alt read counts.
4. Produces a `<replicate>_ref_counts.txt` file.

### 2. Combine counts (`02_combine_counts/`)

`combine_counts.py` merges all per-replicate count files into a single tab-delimited matrix formatted for BIRD:

```
<variant_id>  <N_DNA>  <DNA_rep1_ref>  <DNA_rep1_alt>  ...  <N_RNA>  <RNA_rep1_ref>  <RNA_rep1_alt>  ...
```

Sites with zero total counts across all replicates are dropped.

### 3. Scatter values (`03_bird_scatter_values/`)

Computes the start/end variant indices needed to scatter BIRD across multiple parallel jobs, one chunk per variant or per configured batch size.

### 4. BIRD (`04_bird/`)

Each scatter chunk runs `bird.py`, which:
1. Writes a Stan data file and initialisation file for the chunk's variants.
2. Invokes the compiled `BIRD` Stan model (CmdStan) via MCMC.
3. Reports per-variant median θ, 95 % credible interval, and posterior probability of regulatory difference (`Preg`).

Output columns: `variant_id`, `median_theta`, `CI_lower`, `CI_upper`, `Preg`

## Docker images

Two images are built and published via GitHub Actions:

| Image | Purpose |
|-------|---------|
| `bird_Docker_build/` | Compiles the BIRD Stan model with CmdStan 2.30 and bundles `bird.py` |
| `python_Docker_build/` | Python environment used by the helper scripts |

## Statistical model

BIRD fits a Bayesian binomial model. The key parameters are:

- **p** — alt allele frequency in the DNA library
- **qᵢ** — alt allele frequency in each RNA replicate
- **θ (theta)** — effect size (odds ratio); θ > 1 means alt allele is upregulated in RNA

The Stan model ([BIRD.stan](bird_Docker_build/BIRD.stan)) places a log-normal prior on θ and a Beta prior (parameterised by mode and concentration) on each qᵢ.

## Notes

- The workflow supports unreplicated experiments (single DNA and/or RNA replicate).
- The `min_effect` parameter controls the threshold used to compute `Preg`; `Preg` is the posterior mass beyond ±λ on the odds-ratio scale.
