## Pipeline Overview 🧬

This Nextflow pipeline automates the processing of sequencing data by:

1. **Downloading SRA reads** from a provided accession.
2. **Trimming** the reads using **fastp**.
3. **Performing quality control** with **FastQC**.
4. **Assembling** the reads using **SPAdes**.

The results are organized into the following output directories:

- `RawReads/` – Downloaded raw SRA files.
- `CleanedReads/` – Trimmed sequencing reads.
- `FastQCResults/` – Quality control reports from FastQC.
- `Assemblies/` – Assembled contigs from Skesa.

The pipeline utilizes **Seqera containers** to execute these tasks, ensuring reproducibility and ease of use. It only requires a supplied SRA accession to begin the process, so test data is not needed.

### Output Directory Structure
```
output/
├── Assemblies/
│   └── [all associated SPAdes assembly files]
├── CleanedReads/
│   ├── SRR1556296.R1.trimmed.fq.gz
│   └── SRR1556296.R2.trimmed.fq.gz
├── FastQCResults/
│   ├── SRR1556296_R1_fastqc.zip
│   └── SRR1556296_R2_fastqc.zip
└── RawReads/
    ├── SRR1556296_1.fastq
    └── SRR1556296_2.fastq
```
### Workflow Diagram
```

Workflow Diagram:
-------------------
Sequential (getSRA -> trim -> fastqc) | Parallel (fastqc and assembly simultaneously done)
+--------------------+     +--------------------+      +--------------------+
| getSRA             | ---> | trim              | ---> | fastqc            |
+--------------------+     +--------------------+      +--------------------+
                                |
                                v
                            +--------------------+
                            | assembly           |
                            +--------------------+
```

## Running the pipeline
- Ensure you are in a Conda/Mamba environment where Nextflow and Docker (or Docker Desktop verion) are installed. Note: Please see 'Package Versions' for more information.
- Run the command: `nextflow run main.nf -profile docker`

### Package Versions
* nextflow version 24.10.5.5935
* Docker version 27.4.0, build bde2b89
* nf-core/tools version 3.2.0
* Note: Pipeline was tested on MacOS M2 Pro Chip Arm64
