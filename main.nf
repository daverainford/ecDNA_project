nextflow.enable.dsl=2
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
include {TestInstall} from './modules/test_install/main.nf'
include {AmpliconSuite} from './modules/amplicon_architect/main.nf'
include {DataSummary} from './modules/data_summary/main.nf'
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
params.data = "/scratch/drainford/skcm_ecdna/ecDNA/test_data" 
params.outdir = "/scratch/drainford/skcm_ecdna/ecDNA/results"
params.test = false
params.help = false
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
def helpMessage = 
"""
Usage:
nextflow run script.nf --data <path> --outdir <path> --test <Boolean>

Options:
--data      Path to the directory containing input BAM files OR test FASTQ files.
--outdir    Path to the directory where AmpliconArchitect with publish the results.
--test      Boolean to run the TestInstall process. Default is false.

--help      Print this help message.
"""

if (params.help) {
    println(helpMessage)
    System.exit(0) // Exit the script after printing the help message
}
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
test_reads_channel = Channel.fromFilePairs("${params.data}/*_{1,2}.fastq.gz")
    .ifEmpty { throw new RuntimeException("No FASTQ files found matching pattern in ${params.data}/") }

bams_channel = Channel.fromFilePairs("${params.data}/*_{T,N}.bam")
    .ifEmpty { throw new RuntimeException("No BAM files found matching pattern in ${params.data}/") }
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
workflow {
    if (params.test) {
        TestInstall(test_reads_channel)
    } else {
        def ampliconOutputs = AmpliconSuite(bams_channel)
        DataSummary(ampliconOutputs.aa_output)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
