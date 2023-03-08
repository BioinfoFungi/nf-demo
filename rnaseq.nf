
process INDEX {
    publishDir "output", mode:'copy'

    input:
    path transcriptome 

    output:
    path 'index' 

    script:
    """
    salmon index --threads $task.cpus -t $transcriptome -i index
    """
    
    stub:
     """
    mkdir index
    touch index/seq.bin
    touch index/info.json
    touch index/refseq.bin
    """
}

process QUANT {
    publishDir "output", mode:'copy'

    input:
    path index 
    tuple val(pair_id), path(reads) 

    output:
    path pair_id 

    script:
    """
    salmon quant --threads $task.cpus --libType=U -i $index -1 ${reads[0]} -2 ${reads[1]} -o $pair_id
    """
}

workflow {
  INDEX("$baseDir/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa")
  read_pairs_ch = channel.fromFilePairs("$baseDir/data/ggal/ggal_gut_{1,2}.fq", checkIfExists: true ) 
  QUANT(INDEX.out, read_pairs_ch )
}

//    /ssd2/application/nextflow/build/releases/nextflow-22.11.0-edge-all run a1.nf   -with-docker  quay.io/nextflow/rnaseq-nf:v1.1