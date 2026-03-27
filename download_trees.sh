#!/bin/bash
# ============================================================
# Download phylogenetic tree datasets from original sources
# ============================================================
# This script downloads published, empirical phylogenetic trees
# from their original repositories. All trees have species as
# leaves and come from peer-reviewed studies.
#
# Usage: bash download_trees.sh [--all]
#   Without --all: downloads only the main consensus/MCC trees
#   With --all:    also downloads posterior distributions (large)
# ============================================================

set -e
cd "$(dirname "$0")"

ALL=false
if [ "$1" = "--all" ]; then
    ALL=true
    echo "Downloading ALL files including posterior distributions (this will be large)."
fi

echo ""
echo "=== Phylogenetic Tree Downloader ==="
echo ""

# -------------------------------------------------------
# 1. Mammals — Upham et al. 2019 (5,911 species)
# -------------------------------------------------------
echo "[1/7] Mammals — Upham et al. 2019"
mkdir -p mammals

if [ ! -f mammals/upham2019_mammal_MCC_5911sp.tre ]; then
    curl -sL "https://raw.githubusercontent.com/n8upham/MamPhy_v1/master/_DATA/MamPhy_fullPosterior_BDvr_Completed_5911sp_topoCons_NDexp_MCC_v2_target.tre" \
        -o mammals/upham2019_mammal_MCC_5911sp.tre
    echo "  Downloaded MCC tree (NDexp)"
else
    echo "  MCC tree (NDexp) already exists"
fi

if [ ! -f mammals/upham2019_mammal_FBD_MCC_5911sp.tre ]; then
    curl -sL "https://raw.githubusercontent.com/n8upham/MamPhy_v1/master/_DATA/MamPhy_fullPosterior_BDvr_Completed_5911sp_topoCons_FBDasZhouEtAl_MCC_v2_target.tre" \
        -o mammals/upham2019_mammal_FBD_MCC_5911sp.tre
    echo "  Downloaded MCC tree (FBD)"
else
    echo "  MCC tree (FBD) already exists"
fi

if [ ! -f mammals/upham2019_mammal_100posterior_5911sp.trees ]; then
    curl -sL "https://raw.githubusercontent.com/n8upham/MamPhy_v1/master/_DATA/MamPhy_fullPosterior_BDvr_Completed_5911sp_topoCons_NDexp_v2_sample100_nexus.trees" \
        -o mammals/upham2019_mammal_100posterior_5911sp.trees
    echo "  Downloaded 100 posterior trees"
else
    echo "  100 posterior trees already exists"
fi

# -------------------------------------------------------
# 2. Birds — Jetz et al. 2012 (9,993 species)
# -------------------------------------------------------
echo ""
echo "[2/7] Birds — Jetz et al. 2012"
mkdir -p birds

if [ ! -f birds/AllBirdsHackett1.tre ]; then
    echo "  Downloading 1,000 posterior trees (Hackett backbone, ~185 MB)..."
    curl -sL "https://data.vertlife.org/birdtree/Stage2/HackettStage2_0001_1000.zip" \
        -o birds/HackettStage2_0001_1000.zip
    cd birds
    unzip -o HackettStage2_0001_1000.zip
    # The zip extracts to a nested path
    find . -name "AllBirdsHackett1.tre" -exec mv {} . \;
    rm -rf mnt HackettStage2_0001_1000.zip
    cd ..
    echo "  Downloaded AllBirdsHackett1.tre"
else
    echo "  AllBirdsHackett1.tre already exists"
fi

# -------------------------------------------------------
# 3. Birds — McTavish et al. 2025 (9,183–10,824 species)
# -------------------------------------------------------
echo ""
echo "[3/7] Birds — McTavish et al. 2025"
mkdir -p birds/mctavish2025

for pair in \
    "Tree_versions/Aves_0.1/Clements_2021/MCC.tre:MCC_clements2021.tre" \
    "Tree_versions/Aves_1.0/Clements_2022/phylo_only_select_dates_mean_clements_labels.tre:phylo_dated_clements2022.tre" \
    "Tree_versions/Aves_1.0/Clements_2023/phylo_only_select_dates_mean_clements_labels.tre:phylo_dated_clements2023.tre" \
    "Tree_versions/AlternateRankingTrees/Jetz_aves_1.3/OpenTreeSynth/labelled_supertree/labelled_supertree_ottnames.tre:labelled_supertree_Jetz_backbone.tre"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f "birds/mctavish2025/$dst" ]; then
        curl -sL "https://raw.githubusercontent.com/McTavishLab/AvesData/main/$src" \
            -o "birds/mctavish2025/$dst"
        echo "  Downloaded $dst"
    else
        echo "  $dst already exists"
    fi
done

# -------------------------------------------------------
# 4. Frogs — Portik et al. 2023 (5,326 species)
# -------------------------------------------------------
echo ""
echo "[4/7] Frogs — Portik et al. 2023"
mkdir -p amphibians

for pair in \
    "Supplementary_File_S3_time_tree.tre:portik2023_frog_timetree_5242sp.tre" \
    "R_tree_figure_commands/RAxML_Partitioned_Best_Tree_Bootstraps.tre:portik2023_frog_raxml_best.tre" \
    "Supplementary_File_S4_time_trees_boot.tre:portik2023_frog_100bootstrap_5242sp.tre"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f "amphibians/$dst" ]; then
        curl -sL "https://raw.githubusercontent.com/nhm-herpetology/frog-phylogeny/main/$src" \
            -o "amphibians/$dst"
        echo "  Downloaded $dst"
    else
        echo "  $dst already exists"
    fi
done

# -------------------------------------------------------
# 5. Fish — Rabosky et al. 2018 (11,638–31,516 species)
# -------------------------------------------------------
echo ""
echo "[5/7] Fish — Rabosky et al. 2018"
mkdir -p fish

for pair in \
    "actinopt_12k_raxml.tre.xz:actinopt_12k_raxml.tre" \
    "actinopt_12k_treePL.tre.xz:actinopt_12k_treePL.tre" \
    "actinopt_full.trees.xz:actinopt_full.trees"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f "fish/$dst" ]; then
        curl -sL "https://fishtreeoflife.org/downloads/$src" -o "fish/${src}"
        xz -d "fish/${src}"
        echo "  Downloaded $dst"
    else
        echo "  $dst already exists"
    fi
done

# -------------------------------------------------------
# 6. Seed Plants — Smith & Brown 2018 (353,185–356,305 species)
# -------------------------------------------------------
echo ""
echo "[6/7] Seed Plants — Smith & Brown 2018"
mkdir -p plants

if [ ! -f plants/ALLMB.tre ]; then
    curl -sL "https://github.com/FePhyFoFum/big_seed_plant_trees/releases/download/v0.1/v0.1.zip" \
        -o plants/smith_brown_2018.zip
    cd plants
    unzip -o smith_brown_2018.zip
    mv v0.1/*.tre .
    rm -rf v0.1 smith_brown_2018.zip
    cd ..
    echo "  Downloaded 6 tree variants"
else
    echo "  Already exists"
fi

# -------------------------------------------------------
# 7. Amphibians & Squamates (Dryad — manual download)
# -------------------------------------------------------
echo ""
echo "[7/7] Amphibians & Squamates (Dryad)"
echo "  These datasets require manual download from Dryad (browser auth):"
echo ""
echo "  Jetz & Pyron 2018 — Amphibians (7,238 species):"
echo "    https://datadryad.org/stash/dataset/doi:10.5061/dryad.cc3n6j5"
echo "    Save amph_shl_new_Consensus_7238.tre and amph_shl_new.tre to amphibians/"
echo ""
echo "  Tonini et al. 2016 — Squamates (9,755 species):"
echo "    https://datadryad.org/stash/dataset/doi:10.5061/dryad.db005"
echo "    Download Squamata_Tree_Methods_Data.zip, extract to squamates/"
echo ""
echo "  Pyron et al. 2013 — Squamates (4,161 species):"
echo "    https://datadryad.org/dataset/doi:10.5061/dryad.82h0m"
echo "    Save squam_shl_names.tre and squam_shl.tre to squamates/"

echo ""
echo "=== Done ==="
echo ""
echo "Condamine et al. 2019 family-level trees (218 trees) are included"
echo "in the repository under condamine2019_slowdowns/."

# Summary
echo ""
echo "=== Collection summary ==="
total=$(find . -name "*.tre" -o -name "*.trees" | grep -v ".git" | wc -l | tr -d ' ')
echo "Total tree files: $total"
