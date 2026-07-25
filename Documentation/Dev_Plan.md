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
- The available assets include both raw FASTQ reads and precomputed VCF variant calls.
- FASTQ and VCF files may represent the same samples, overlapping sample sets, or different samples; sample identity and provenance must be verified before integration.
- Supplied VCFs will be retained as primary analytical assets rather than treated only as products to regenerate from FASTQ.
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
5. Create a metadata table containing breed name, sample identifier, available FASTQ read pairs and/or VCF files, file source, checksum, size, acquisition date, sequencing platform, read depth, VCF caller and version, VCF filtering status and cohort composition, reference genome version, expected sex, read group, and known pedigree or replicate relationships.
6. Build an explicit FASTQ-to-VCF sample map and flag files whose sample identity or reference build is uncertain.

Recommended tools:

- R: biomaRt
- Python: requests, Bio.SeqIO, pandas

Deliverables:

- Reference data manifest
- Gene and protein sequence tables
- Analysis-ready FASTQ/VCF inventory and sample crosswalk

### Phase 2: Input Ingestion, Validation, and Quality Control

Objectives:

- Validate both raw-read and precomputed-variant assets before analysis.
- Prepare FASTQ reads for alignment while preserving an independently supplied VCF analysis track.

Tasks:

1. Verify file integrity with checksums and confirm compression and format validity.
2. For FASTQ assets, confirm paired-end mate consistency and sample naming; inspect read quality, adapter contamination, GC distribution, duplication, and overrepresented sequences; trim adapters or low-quality bases only when QC indicates a need; and record read counts before and after filtering.
3. For VCF assets, inspect headers, sample names, contig definitions, reference build, caller metadata, and filter fields; check sorted order, duplicate records, malformed alleles, genotype completeness, depth, genotype quality, transition/transversion ratio, and PASS rates; compress and index files when required; and split multiallelic records and left-align/normalize alleles against the matching cat reference without discarding the original VCF.
4. Generate separate QC summaries for FASTQ and VCF assets and record all transformations in the processing log.

Recommended tools:

- FastQC
- fastp or Trimmomatic
- MultiQC
- bcftools stats, norm, query, and +fill-tags
- vcftools
- bgzip / tabix

Recommended workflow logic:

- FASTQ track: input FASTQ -> integrity checks -> QC -> conditional trimming -> alignment
- VCF track: supplied VCF -> header/build validation -> normalization -> variant QC -> annotation-ready VCF

Deliverables:

- Cleaned reads
- Original and normalized/indexed supplied VCFs
- FASTQ and VCF QC reports
- Sample identity and processing log

### Phase 3: FASTQ Alignment and Mapping

Objectives:

- Align reads from Rag Doll and Maine Coon samples to a reference genome.
- Generate alignment files suitable for variant calling.

Tasks:

1. Align reads using BWA-MEM or BOWTIE2.
2. Sort and index BAM files.
3. Mark duplicates.
4. Validate alignment quality and depth.
5. Confirm BAM sample/read-group labels agree with the FASTQ-to-VCF sample map.

Recommended tools:

- BWA-MEM
- BOWTIE2
- SAMtools
- Picard

Deliverables:

- BAM files
- Alignment quality summaries
- Coverage statistics per target gene

### Phase 4: FASTQ-Derived Calling, VCF Harmonization, and Annotation

Objectives:

- Derive variants from FASTQ while independently leveraging the supplied VCF calls.
- Measure agreement between supplied and FASTQ-derived variants where samples overlap.
- Produce a traceable, harmonized variant resource without obscuring call-set provenance.
- Annotate variants by gene, consequence, and potential functional impact.

Tasks:

1. Run per-sample variant calling from aligned FASTQ reads using GATK HaplotypeCaller in GVCF mode or a validated equivalent.
2. Perform joint genotyping across compatible FASTQ-derived samples and apply documented hard filters or VQSR when sample size supports it.
3. Harmonize supplied and FASTQ-derived VCFs to the same reference assembly, contig naming convention, representation, and target intervals; use validated liftover only when source builds differ.
4. Verify sample identity for overlapping samples using genotype concordance, allele balance, sex-linked markers where appropriate, and contamination/relatedness checks.
5. Compare call sets using site-level and genotype-level concordance, stratified by PASS status, variant type, genomic context, depth, and target gene.
6. Classify each variant as supported by both call sets, present only in the supplied VCF, present only in FASTQ-derived calls, or discordant in genotype or allele representation.
7. Investigate discordant high-impact collagen or FLA variants using BAM evidence before inclusion in the high-confidence set.
8. Retain source-specific VCFs and create a harmonized analysis VCF/table with explicit provenance fields; do not treat absence from a non-callable region as a reference genotype.
9. Annotate variants with gene context, predicted consequence, population/cohort frequency when available, and potential functional impact.
10. Extract variants overlapping collagen genes, FLA loci, regulatory regions, and defined flanking intervals.

Recommended tools:

- GATK
- SnpEff / VEP
- bcftools isec, merge, norm, stats, gtcheck, and query
- Picard GenotypeConcordance or hap.py for concordance assessment
- VerifyBamID2 or an appropriate contamination/identity checker

Deliverables:

- Filtered FASTQ-derived call set
- Normalized supplied VCF call set
- Sample identity and call-set concordance report
- Provenance-aware harmonized and annotated VCFs
- Collagen- and FLA-focused variant tables with evidence-source labels

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

1. Extract reference gene sequences and define callable regions for each sample.
2. Select variants from the harmonized, provenance-aware call set using documented confidence rules.
3. Apply phased genotypes where available to generate haplotype sequences; otherwise preserve heterozygous ambiguity rather than forcing a single allele.
4. Generate sample-level consensus sequences before deriving any breed-level summary.
5. Compare sample- and breed-specific sequences to the reference cat and human sequences.
6. Identify amino acid changes caused by nonsynonymous variants and record whether each is supported by supplied VCF, FASTQ-derived calls, or both.

Recommended tools:

- Python: Bio.Seq, Bio.SeqIO, Bio.SeqRecord, pandas
- R: Biostrings, VariantAnnotation

Deliverables:

- Breed-specific DNA and protein sequences
- Variant-to-protein impact summary with call-set provenance and confidence
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
- Inventory FASTQ and VCF assets and create the sample crosswalk

### Milestone 2: Dual-Input QC and Processing

- Implement FASTQ QC and conditional trimming workflow
- Implement supplied-VCF validation, normalization, and QC workflow
- Verify reference-build compatibility and sample identity metadata
- Create reproducible shell or Python workflow

### Milestone 3: Alignment, Calling, and Concordance

- Implement read mapping and BAM generation
- Execute FASTQ-derived variant calling for both breeds
- Compare overlapping samples against supplied VCFs
- Produce filtered, normalized, and provenance-aware VCF outputs

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
  - pysam or cyvcf2 for indexed VCF/BCF and BAM access

### Supporting tools

- BWA-MEM / BOWTIE2
- SAMtools / bcftools
- GATK
- FastQC / MultiQC / fastp or Trimmomatic
- bgzip / tabix
- Picard GenotypeConcordance or hap.py

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
- Use pysam or cyvcf2 alongside Biopython for scalable VCF/BCF genotype access, normalization-aware queries, and BAM evidence retrieval.
- Generate tables for downstream R/Bioconductor and MATLAB/Octave/Scilab workflows.
- Serve as part of the bridge between raw reads, supplied variants, reconstructed sequences, and structured analytical outputs.

## 8. Deliverables

The project should produce the following outputs:

1. A reproducible pipeline for Rag Doll and Maine Coon sequence analysis
2. A complete FASTQ/VCF sample manifest with checksums, reference builds, and provenance
3. QC reports for raw reads, supplied VCFs, alignments, and FASTQ-derived calls
4. A concordance report comparing supplied and FASTQ-derived variants for overlapping samples
5. A provenance-aware harmonized VCF and curated collagen/FLA variant table
6. A comparative alignment report across human, cat reference, Rag Doll, and Maine Coon sequences
7. A PTM/motif interpretation report identifying candidate sequence changes of biological interest
8. Figures and summary tables suitable for presentation or publication

## 9. Recommended Execution Order

1. Prepare reference genomes, annotations, and target gene/FLA intervals
2. Inventory FASTQ and VCF assets and resolve the sample crosswalk
3. Validate and normalize supplied VCFs without altering the originals
4. QC, conditionally trim, and align FASTQ reads
5. Call and filter FASTQ-derived variants
6. Harmonize call sets and assess sample identity and genotype concordance
7. Review discordant high-impact collagen and FLA variants against read evidence
8. Build the provenance-aware analysis call set and annotate collagen/FLA variants
9. Generate sample- and breed-specific consensus or haplotype sequences
10. Compare sequences and identify nonsynonymous changes
11. Evaluate lysine/proline motif changes and PTM potential
12. Prepare final report and figures

## 10. Risk Notes and Mitigation

- Missing or low-quality WGS input may limit confident variant calling.
- Reference genome version mismatches can cause annotation inconsistencies.
- Supplied VCFs may use different callers, filters, contig names, variant representations, or cohort assumptions; preserve originals and normalize copies before comparison.
- FASTQ and VCF sample labels may not refer to the same biological individuals; require metadata reconciliation and genotype-based identity checks before merging.
- A VCF containing only variant sites cannot establish callability at absent positions; use gVCF blocks, BAM depth, or callable-region masks to distinguish homozygous reference from missing evidence.
- Breed-level conclusions are vulnerable to small sample size, relatedness, uneven coverage, and caller-specific artifacts; report sample-level results and stratify by evidence source.
- Some variants may have uncertain biological significance without experimental validation.
- To reduce risk, maintain immutable raw inputs, checksums, a strict metadata/provenance log, callable-region masks, and version-controlled analysis scripts.

## 11. Recommended Next Step

Begin by inventorying all FASTQ and VCF files and constructing the sample crosswalk. Then run a minimal dual-track pilot on one representative sample from each breed: validate and normalize its supplied VCF, process and align its FASTQ reads, generate an independent call set, and quantify concordance. Resolve reference-build, identity, and filtering discrepancies before scaling to the full dataset.
