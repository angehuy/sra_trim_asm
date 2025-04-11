#!/usr/bin/env nextflow

/*
================================================================================
    PROCESSES
================================================================================
*/

// 1. Download and extract SRA reads
process getSRA {
    publishDir 'results', mode: 'copy'
    container 'community.wave.seqera.io/library/sra-tools:3.2.1--2063130dadd340c5'

    input:
        val accession

    output:
        tuple val(accession), path("RawReads/${accession}_1.fastq"), path("RawReads/${accession}_2.fastq")

    script:
    """
    mkdir -p SRA
    mkdir -p RawReads
    prefetch "${accession}" --output-directory "SRA/"
    fasterq-dump "${accession}" --outdir "RawReads/" --split-files --skip-technical
    """
}

process trim {
    publishDir 'results', mode: 'copy'
    container 'community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690'

    input:
        tuple val(sample), path(read1), path(read2)

    output:
        tuple val(sample), path("CleanedReads/${sample}.R1.trimmed.fq.gz"), path("CleanedReads/${sample}.R2.trimmed.fq.gz")

    script:
    """
    mkdir -p CleanedReads
    fastp \\
        -i ${read1} \\
        -I ${read2} \\
        -o CleanedReads/${sample}.R1.trimmed.fq.gz \\
        -O CleanedReads/${sample}.R2.trimmed.fq.gz
    """
}




// 3. Perform FastQC on trimmed reads

process fastqc {
    publishDir 'results', mode: 'copy'
    container 'community.wave.seqera.io/library/sra-tools:3.2.1--d20c35ade6b929ad'
    input:
        tuple val(sample), path(read1), path(read2)

    output:
        path "FastQCResults/*.zip", emit: qc_results

    script:
    """
    mkdir -p FastQCResults
    fastqc "${read1}" "${read2}" --outdir FastQCResults/
    """
}


// 4. Assemble with SPAdes
process assembly {
    publishDir 'results/Assemblies', mode: 'copy'
    container 'community.wave.seqera.io/library/spades:4.1.0--2f0aef15bea8ba99'

    input:
        tuple val(sample), path(read1), path(read2)

    output:
        path "Assemblies/"

    script:
    """
    mkdir -p Assemblies

    spades.py -1 "${read1}" -2 "${read2}" -o Assemblies/

    """
}


process assembly2 {
    publishDir 'results/Assemblies', mode: 'copy'
    container 'community.wave.seqera.io/library/skesa:2.4.0--c981dd59ac146fb5'

    input:
        tuple val(sample), path(read1), path(read2)

    output:
        path "Assemblies/${sample}_assembly.fna"

    script:
    """
    mkdir -p Assemblies

    skesa \\
        --reads "${read1},${read2}" \\
        --cores 4 \\
        --min_contig 1000 \\
        --contigs_out Assemblies/${sample}.fna

    """
}

process assembly3 {
    publishDir 'results/Assemblies', mode: 'copy'
    container 'community.wave.seqera.io/library/skesa:2.5.1--d0ff170568df269c'

    input:
        tuple val(sample), path(read1), path(read2)

    output:
        path("assemblies/${sample}.fna")

    script:
    """
    mkdir -p assemblies

    skesa \\
        --reads "${read1},${read2}" \\
        --cores 4 \\
        --min_contig 1000 \\
        --contigs_out assemblies/${sample}.fna
    """
}


/*
================================================================================
    WORKFLOW
================================================================================
*/

workflow {
    // Can be modified to include more accessions
    accessions = Channel.of("SRR1556296")

    sra_data = accessions
        | getSRA

    trimmed_reads = sra_data
        | trim

    fastqc_results = trimmed_reads
        | fastqc

    assembly_results = trimmed_reads
        | assembly
}

