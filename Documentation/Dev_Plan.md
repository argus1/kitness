# Development Plan: Comparative Cat Genomics Study

## 1. Project Goal

Build a reproducible bioinformatics workflow to compare collagen-related genomic variation between two cat breeds, Rag Doll and Maine Coon, against a human reference and the domestic cat reference genome. The study will also evaluate Feline Leukocyte Antigen (FLA) loci involved in collagen peptide presentation, with the goal of understanding how breed-specific immunogenetic variation may contribute to arthritis progression and how feline FLA-mediated collagen presentation compares to human HLA-collagen biochemical machinery.

## 2. Core Biological Question

The central hypothesis is that Rag Doll and Maine Coon genomes may contain breed-specific variants in collagen genes and FLA antigen-presentation loci that alter collagen structure, peptide processing, and immune recognition, with implications for arthritis susceptibility, progression, and cross-species comparison to human HLA-mediated collagen biology.

The target genes should be prioritized as:

- COL1A1
- COL1A2
- COL3A1

These are high-value collagen targets for cross-species structural comparison and PTM analysis.

## 3. Working Assumptions

- The study is based on whole-genome sequencing (WGS) data from two cat breeds.
- The workflow will use a hybrid strategy combining:
  - Omics Logic-style guided workflow thinking for reproducible pipeline structure
  - Bioconductor and R for statistical and sequence analysis
  - Python and Biopython for sequence manipulation and scripting
  - Optional MATLAB/Octave/Scilab integration for exploratory analysis and cross-platform validation
- The analysis will emphasize sequence-level interpretation rather than direct experimental validation.

## 4. Proposed Workflow (Gemini-style / End-to-End Bioinformatics Plan)

### Phase 1: Data Acquisition and Reference Preparation

Objectives:

- Acquire reference genomes and annotation resources.
- Define a reproducible input set for the two breeds and comparison datasets.

Tasks:

1. Download the human reference assembly GRCh38.
2. Download the domestic cat reference genome (Felis catus, FeliCa_1.0 or the most appropriate current assembly).
3. Retrieve collagen gene annotations for human and cat reference genomes.
4. Collect transcript and protein sequences for the selected collagen genes.
5. Create a metadata table containing:
   - Breed name: Rag Doll / Maine Coon
   - Sample identifier
   - File type and source
   - Sequencing platform and read depth
   - Reference genome version

Recommended tools:

- R: biomaRt
- Python: requests, Bio.SeqIO, pandas

Deliverables:

- Reference data manifest
- Gene and protein sequence tables
- Analysis-ready input inventory

### Phase 2: Raw Data Ingestion and Quality Control

Objectives:

- Prepare sequencing reads for downstream analysis.
- Remove technical artifacts and low-quality sequence segments.

Tasks:

1. Inspect FASTQ files for read quality, adapter contamination, and duplication.
2. Trim low-quality bases and remove adapters.
3. Generate QC reports for each sample.
4. Record read counts before and after filtering.

Recommended tools:

- FastQC
- Trimmomatic
- MultiQC

Recommended workflow logic:

- Input FASTQ -> QC -> trim -> QC summary -> proceed to alignment

Deliverables:

- Cleaned reads
- QC reports
- Sample processing log

### Phase 3: Alignment and Mapping

Objectives:

- Align reads from Rag Doll and Maine Coon samples to a reference genome.
- Generate alignment files suitable for variant calling.

Tasks:

1. Align reads using BWA-MEM or BOWTIE2.
2. Sort and index BAM files.
3. Mark duplicates.
4. Validate alignment quality and depth.

Recommended tools:

- BWA-MEM
- BOWTIE2
- SAMtools
- Picard

Deliverables:

- BAM files
- Alignment quality summaries
- Coverage statistics per target gene

### Phase 4: Variant Calling and Annotation

Objectives:

- Identify breed-specific variants in collagen genes and nearby genomic regions.
- Annotate variants by gene, consequence, and potential functional impact.

Tasks:

1. Run variant calling using GATK or a compatible workflow.
2. Generate VCF files for Rag Doll and Maine Coon.
3. Filter variants by confidence and quality thresholds.
4. Annotate variants with gene context and predicted impact.
5. Extract variants overlapping collagen genes of interest.

Recommended tools:

- GATK
- SnpEff / VEP
- bcftools

Deliverables:

- Variant call sets
- Annotated VCFs
- Collagen-focused variant table

### Phase 5: FLA Immunogenetics and Collagen Presentation Analysis

Objectives:

- Identify FLA class II genes and linked variants relevant to collagen peptide presentation.
- Evaluate whether breed-specific FLA variation could influence the presentation of collagen-derived peptides and downstream immune recognition.
- Compare feline FLA-collagen presentation mechanisms with human HLA-collagen antigen-processing pathways.

Tasks:

1. Annotate FLA class II loci and nearby regulatory regions relevant to antigen presentation.
2. Compare FLA allele patterns between Rag Doll, Maine Coon, and reference cats.
3. Link FLA variation to collagen-derived peptide compatibility, antigen processing, and predicted T-cell recognition.
4. Frame the results in the context of arthritis pathophysiology and human autoimmune collagen biology.

Recommended tools:

- R: VariantAnnotation, GenomicRanges, biomaRt
- Python: pandas, Bio.Seq, regex-based peptide motif analysis
- Optional: immunoinformatics tools for peptide-binding motif scoring

Deliverables:

- FLA-focused variant and allele summary
- Collagen presentation hypothesis table
- Cross-species comparison report linking feline FLA and human HLA collagen presentation mechanisms

### Phase 6: Sequence Reconstruction and Consensus Generation

Objectives:

- Convert variant information into gene-level sequence representations.
- Build breed-level consensus sequences for collagen genes.

Tasks:

1. Extract reference gene sequences.
2. Apply variants to generate consensus sequences for each breed.
3. Compare breed-specific sequences to the reference cat and human sequences.
4. Identify amino acid changes caused by nonsynonymous variants.

Recommended tools:

- Python: Bio.Seq, Bio.SeqIO, Bio.SeqRecord, pandas
- R: Biostrings, VariantAnnotation

Deliverables:

- Breed-specific DNA and protein sequences
- Variant-to-protein impact summary
- Comparison table of reference vs breed sequences

### Phase 7: Comparative Alignment and Structural Interpretation

Objectives:

- Determine whether changes are conserved, novel, or likely to alter collagen structure.
- Identify residues that may affect PTM potential.

Tasks:

1. Perform multi-sequence alignment among:
   - Human reference collagen sequence
   - Cat reference collagen sequence
   - Rag Doll consensus sequence
   - Maine Coon consensus sequence
2. Inspect amino acid substitutions in the collagen triple-helix region and adjacent domains.
3. Flag variants affecting lysine or proline residues.
4. Compare conservation patterns across species and breeds.

Recommended tools:

- R: msa, Biostrings, DECIPHER, BiocParallel
- Python: Bio.Align, Bio.SeqUtils

Deliverables:

- Alignment images and reports
- Mutation summary table
- Candidate residues for PTM interpretation

### Phase 8: PTM and Structural Motif Prediction

Objectives:

- Translate sequence variation into a biologically interpretable hypothesis about collagen modification potential.

Tasks:

1. Search for motifs relevant to collagen biology, including glycine-X-Y triplets and lysine/proline enrichment patterns.
2. Evaluate whether variants alter potential hydroxylation or cross-linking motifs.
3. Compare predicted motif frequency and distribution across breeds.
4. Create a simple scoring framework for candidate “branch-point proxy” sites.

Recommended tools:

- R: Biostrings, custom scripts
- Python: regex-based motif scanning, pandas, matplotlib

Deliverables:

- PTM candidate site table
- Motif distribution plots
- Interpretation report for breed-specific differences

## 5. Development Milestones

### Milestone 1: Project Setup and Reference Infrastructure

- Create project folder structure
- Define sample metadata schema
- Download and localize reference genomes
- Build initial sequence and gene manifest

### Milestone 2: Read Processing Pipeline

- Implement QC and trimming workflow
- Verify sample readiness for alignment
- Create reproducible shell or Python workflow

### Milestone 3: Alignment and Variant Calling

- Implement read mapping and BAM generation
- Execute variant calling for both breeds
- Produce filtered VCF outputs

### Milestone 4: Sequence Comparison and Annotation

- Generate consensus sequences
- Compare human, cat, Rag Doll, and Maine Coon proteins
- Annotate variants by impact
- Integrate FLA immunogenetics with collagen sequence analysis

### Milestone 5: PTM Interpretation and Reporting

- Build motif analysis and scoring workflow
- Produce figures and a narrative summary
- Prepare final deliverables for review

## 6. Recommended Tool Stack

### Primary stack

- R with Bioconductor
  - biomaRt
  - Biostrings
  - msa
  - VariantAnnotation
  - GenomicRanges
  - BiocParallel

- Python with Biopython
  - Bio.Seq
  - Bio.SeqIO
  - Bio.Align
  - Bio.SeqUtils
  - pandas
  - matplotlib

### Supporting tools

- BWA-MEM / BOWTIE2
- SAMtools / bcftools
- GATK
- FastQC / MultiQC / Trimmomatic

## 7. Integration Points for MATLAB / Octave / Scilab and Biopython

### MATLAB

Integration should be treated as an optional validation and visualization layer rather than a primary execution engine.

Possible integration points:

- Import FASTA, FASTQ, VCF, and BAM-derived summaries into MATLAB tables.
- Use the Bioinformatics Toolbox for sequence alignment, sequence analysis, and visualization.
- Build custom scripts to compare amino acid substitutions and motif frequencies.
- Export analysis results back to CSV/TSV for downstream reporting in R or Python.

Suggested workflow:

- Python or R generates intermediate tables.
- MATLAB reads those tables and creates plots, dashboards, or validation summaries.

### Octave

Octave can be used for lighter-weight analysis and prototyping where a full MATLAB license is unavailable.

Possible integration points:

- Use Octave for sequence statistics, visualization, and custom motif scanning.
- Read CSV/TSV outputs generated by Python or R.
- Prototype alignment or motif scoring logic before migrating to a more production-ready environment.
- Integrate via simple file-based exchange rather than direct API calls.

### Scilab

Scilab can serve as an academic or teaching-oriented alternative for data exploration.

Possible integration points:

- Import sequence-derived tables into Scilab for exploratory statistics.
- Implement custom motif search and plotting routines.
- Validate that the same biological observations are preserved across toolchains.

### Biopython

Biopython should be the main Python-based sequence analysis layer.

Recommended integration points:

- Parse and manipulate FASTA and FASTQ files with SeqIO.
- Perform sequence alignment and multiple sequence alignment tasks via Bio.Align.
- Extract and compare protein sequences and codon translation logic.
- Generate tables for downstream R/Bioconductor and MATLAB/Octave/Scilab workflows.
- Serve as the bridge between raw sequencing data and structured analytical outputs.

## 8. Deliverables

The project should produce the following outputs:

1. A reproducible pipeline for Rag Doll and Maine Coon sequence analysis
2. A curated variant table focused on collagen genes
3. A comparative alignment report across human, cat reference, Rag Doll, and Maine Coon sequences
4. A PTM/motif interpretation report identifying candidate sequence changes of biological interest
5. Figures and summary tables suitable for presentation or publication

## 9. Recommended Execution Order

1. Prepare reference genomes and gene lists
2. Build QC and trimming workflow
3. Align reads and call variants
4. Annotate FLA loci relevant to collagen peptide presentation
5. Generate breed-specific consensus sequences
6. Compare sequences and identify non-synonymous changes
7. Evaluate lysine/proline motif changes and PTM potential
8. Prepare final report and figures

## 10. Risk Notes and Mitigation

- Missing or low-quality WGS input may limit confident variant calling.
- Reference genome version mismatches can cause annotation inconsistencies.
- Some variants may have uncertain biological significance without experimental validation.
- To reduce risk, maintain a strict metadata log and version-controlled analysis scripts.

## 11. Recommended Next Step

Begin with a minimal viable pipeline on one representative sample from each breed, confirm that reads align correctly, and then scale to the full dataset once the workflow is validated.
