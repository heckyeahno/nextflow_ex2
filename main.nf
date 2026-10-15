nextflow.enable.dsl = 2

// Étape 1 : télécharger l'arbre phylogénétique (aucune entrée)
process downloadTree {
    output:
    path "ref.nw.gz"

    script:
    """
    wget https://booster.pasteur.fr/static/files/primates/ref.nw.gz
    """
}

// Étape 2 : lister les noms des tips avec gotree
process listTips {
    publishDir "results", mode: 'copy'

    input:
    path tree

    output:
    path "tips.txt"

    script:
    """
    gotree stats tips -i ${tree} > tips.txt
    """
}

workflow {
    tree = downloadTree()
    tips = listTips(tree)

    // Compter les tips sans nouveau process : opérateurs sur le canal de sortie
    tips
        .splitCsv(sep: '\t', header: true)   // 1 élément par ligne (l'en-tête est consommé)
        .count()                             // nombre d'éléments
        .view { n -> "The tree has ${n} tips" }
}
