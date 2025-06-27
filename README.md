# FIJI_Macros

This repository contains a collection of ImageJ/Fiji macros for quantitative image analysis in biomedical research. The macros are designed for a variety of applications. Each macro is tailored for specific workflows and imaging modalities.

**There are 99 macros described in this document.**

**Summary Table:**

| Prefix      | Meaning/Modality                        |
|-------------|-----------------------------------------|
| All_        | General/batch/preprocessing macros      |
| BioVoxxel_  | Advanced 2D/3D analysis tools           |
| CT_         | Computed Tomography (CT)                |
| EM_         | Electron Microscopy                     |
| IF_         | Immunofluorescence (2D)                 |
| IF3D_       | Immunofluorescence (3D stacks)          |
| IF4D_       | Immunofluorescence (4D: 3D + time)      |
| PHC_        | Phase Contrast Microscopy               |
| WF_         | Widefield Microscopy                    |
| WSI_        | Whole Slide Imaging (histology slides)  |

---

### Adiposoft17.ijm / old/Adiposoft16.ijm
- **Purpose:** Automated and manual quantification of adipocyte size and number in microscopy images.
- **Features:** Batch processing, edge exclusion, calibration in microns or pixels, manual ROI editing.
- **Output:** Results as `.xls` and `.csv`, annotated images.

### Adipophilin.ijm
- **Purpose:** Quantifies adipophilin-positive areas in tissue sections.
- **Features:** Manual ROI selection, tissue/adipophilin thresholding, artifact removal.
- **Output:** Quantification table and annotated images.

### All_exploreFeatures.ijm
- **Purpose:** Extracts and summarizes image features (bit depth, intensity, Otsu stats) for batches.
- **Features:** Batch processing, Excel export.
- **Output:** `.xls` report of image features.

### All_ReduceDimensionality.ijm
- **Purpose:** Reduces dimensionality of multi-dimensional images (channels, slices, frames).
- **Features:** Batch and single-file mode, flexible dimension selection.
- **Output:** Split images per dimension.

### All_removeArtefacts.ijm
- **Purpose:** Removes unwanted regions/artifacts from images by manual selection.
- **Features:** Interactive background selection and artifact removal.
- **Output:** Preprocessed images.

### All_RotateReslice.ijm
- **Purpose:** Rotates and reslices CT images for orientation correction.
- **Features:** User-defined rotation angle, batch and single-file mode.
- **Output:** Rotated/resliced images.

### All_SplitFields.ijm
- **Purpose:** Splits multi-field images (e.g., confocal) into individual fields.
- **Features:** User-defined grid (columns/rows), batch and single-file mode.
- **Output:** Individual field images.

### All_SplitSamples.ijm
- **Purpose:** Splits multi-sample images (e.g., WSI) into single-sample images.
- **Features:** User-defined number of samples, batch and single-file mode.
- **Output:** Cropped images per sample.

### All_SVSchangeFormat.ijm
- **Purpose:** Converts Aperio SVS and other formats to TIFF/HDF5.
- **Features:** Batch and single-file mode, supports various input formats.
- **Output:** Converted images in new format.

### BioVoxxel_Toolbox.ijm
- **Purpose:** Advanced toolbox for 2D/3D image analysis, including particle analysis, shape descriptors, and feature extraction.
- **Features:** Analyze particles by shape, edge correction, field of view count, threshold checks, background correction, and more.
- **Output:** Quantitative results, processed images, and overlays for further analysis.

### BioVoxxel_3D_Box.ijm
- **Purpose:** Suite of 3D image processing tools for isotropic correction, filtering, and label analysis.
- **Features:** Voxel and image isotropy, flat field correction, Difference of Gaussian, recursive filtering, threshold labeling, label splitting, object inspection, and neighbor analysis.
- **Output:** Enhanced and processed 3D images, label maps, and analysis results.

### CT_BoneAnalysis_FemurMonetite.ijm
- **Purpose:** Analyze bone and scaffold in femur CT images, including volume and intensity quantification.
- **Features:** Prism selection, manual annotation of implants, interpolation, and quantification inside/outside scaffold.
- **Output:** Volume and intensity measurements, annotated images, and results tables.

### CT_BoneFat_PrePost.ijm
- **Purpose:** Quantify bone marrow fat using pre- and post-decalcification CT images.
- **Features:** Segments bone and fat, measures volumes, calculates fat ratio, and supports user-defined thresholds.
- **Output:** Fat and bone volume ratios, results tables, and processed images.

### CT_LiverTumors.ijm
- **Purpose:** Semiautomatic segmentation and quantification of 3D tumors in microCT images.
- **Features:** Automatic/manual annotation, tumor volume and diameter calculation, batch processing.
- **Output:** Tumor volume and size data, annotated images, and Excel/CSV reports.

### CT_Manguito.ijm
- **Purpose:** Analyze inflammation and fat in CT images of the rotator cuff.
- **Features:** Manual region selection, automatic detection of inflammation and fat, peripheral ring quantification.
- **Output:** Quantitative results for inflammation and fat, annotated images, and summary tables.

### CT_removeRingArtefactsFFT.ijm
- **Purpose:** Remove ring artifacts from microCT images using FFT-based filtering.
- **Features:** Batch processing of DICOM folders, FFT filtering, and automated artifact removal.
- **Output:** Preprocessed images with reduced artifacts, ready for further analysis.

### CT_tibiaCartige.ijm
- **Purpose:** Automatic segmentation and quantification of tibia cartilage in microCT images.
- **Features:** Cartilage segmentation, thickness mapping, condyle ROI analysis, and profile plotting.
- **Output:** Cartilage thickness maps, quantitative tables, and annotated images.

### Drawing Tools.txt
- **Purpose:** Custom drawing tools for manual annotation and editing in ImageJ.
- **Features:** Pencil, paintbrush, eraser, spray can, flood fill, and arrow tools with adjustable parameters.
- **Output:** Manually annotated or edited images.

### EM_Liposoms.ijm
- **Purpose:** Semiautomatic segmentation and quantification of liposomes in electron microscopy images.
- **Features:** Annotation of single, multilamellar, and inner liposomes, ellipse fitting, ROI management, and size feature extraction.
- **Output:** Annotated ROI sets, summary statistics, and Excel reports.

### IF_ATF4.ijm
- **Purpose:** Automatic classification of ATF4+/- cells in confocal IF images (DAPI + ATF4).
- **Features:** Nuclei segmentation, marker-controlled watershed, quantification of ATF4+ cells.
- **Output:** QuantificationResults.xls, annotated images.

### IF_Angiogenesis.ijm
- **Purpose:** Quantification of angiogenesis (vessel area and number) in IF images.
- **Features:** Manual ROI selection, tissue/vessel segmentation, vessel counting.
- **Output:** Quantification_angiogenesis.xls, annotated images.

### IF_AorticRings.ijm
- **Purpose:** Quantifies aortic ring and branches in 2D/3D images.
- **Features:** Automatic detection, manual editing, skeleton analysis for branch length/number.
- **Output:** _QuantifiedBranches.xls, tagged skeleton images.

### IF_Bacteria.ijm
- **Purpose:** Quantifies bacteria in IF images (DAPI, red, green).
- **Features:** Segmentation, marker-controlled watershed, intensity filtering.
- **Output:** Bacteria_results_individual.xls, Bacteria_results_averages.xls, annotated images.

### IF_BiofilmLiveDead.ijm
- **Purpose:** Quantifies live/dead bacteria in biofilm images.
- **Features:** Thresholding, area calculation, live/dead ratio.
- **Output:** QuantificationResults_IF_BiofilmLiveDead.xls, overlay images.

### IF_CardioFibroblast.ijm
- **Purpose:** Counts fibroblasts in cardiac tissue based on double phenotype (SMA+, CAV-).
- **Features:** Tissue/ROI selection, marker segmentation, vessel exclusion.
- **Output:** QuantificationResults_IF_FibroblastCount.xls.

### IF_CardiomyocytesCount.ijm
- **Purpose:** Automatic detection and quantification of cardiomyocytes.
- **Features:** Tissue/membrane segmentation, manual editing, area measurement.
- **Output:** Quantification_Cardiomyocytes.xls, SegmentationResults.xls, annotated images.

### IF_Centriolos.ijm
- **Purpose:** Quantifies centrioles and their distances to nuclei in IF images.
- **Features:** 3D stack processing, nuclei/centriole segmentation, distance calculation.
- **Output:** QuantificationResults_IF_Centriolos.xls.

### IF_CellClassPhenotype.ijm
- **Purpose:** Automatic classification of cell phenotypes (e.g., DAPI + marker).
- **Features:** Nuclei segmentation, marker-controlled watershed, phenotype quantification.
- **Output:** Quantification_[phName]CellPhenotype.xls, annotated images.

### IF_CellClassDoublePhenotype.ijm
- **Purpose:** Classifies cells based on single/double phenotypes (e.g., DAPI + 3 markers).
- **Features:** Tissue/ROI segmentation, marker segmentation, phenotype counting.
- **Output:** QuantificationResults.xls.

### IF_CellClassLifeDead.ijm
- **Purpose:** Classifies cells as live/dead based on phenotype markers.
- **Features:** DAPI segmentation, marker segmentation, phenotype quantification.
- **Output:** Quantification_LifeDead.xls.

### IF_CellCount.ijm
- **Purpose:** Counts nuclei in 2D confocal images.
- **Features:** Channel selection, size filtering, batch mode.
- **Output:** Quantification_IF2D_CellCount.xls, annotated images.

### IF_DAPI_Green_inNuclei.ijm
- **Purpose:** Quantifies DAPI and marker areas, computes DAPI/marker ratio.
- **Features:** Channel selection, background correction, thresholding, area measurement.
- **Output:** IF_quantification.xls, annotated images.

### IF_DAPI_Green_perNucleus.ijm
- **Purpose:** Quantifies marker intensity within each nucleus.
- **Features:** Nuclei segmentation, per-nucleus measurement.
- **Output:** IF_quantification_[image].xls, annotated images.

### IF_FibrinMesh3D.ijm
- **Purpose:** 3D analysis of fibrin mesh in confocal images.
- **Features:** 3D segmentation, BoneJ analysis, thickness/length quantification.
- **Output:** Quantification_FibrinMesh.xls, segmentation images.

### IF_FISH.ijm
- **Purpose:** Quantifies FISH signals (red/green) in multi-channel images.
- **Features:** Channel selection, background correction, manual ROI, artifact removal.
- **Output:** Processed images, quantification tables.

### IF_FociClass.ijm
- **Purpose:** Automatic detection and classification of DNA damage foci.
- **Features:** Nuclei segmentation, marker-controlled watershed, phenotype quantification.
- **Output:** Quantification tables, annotated images.

### IF_FociTissue.ijm
- **Purpose:** Quantifies foci (e.g., DNA damage) in tissue.
- **Features:** Tissue/nuclei segmentation, foci detection, area/intensity measurement.
- **Output:** Foci_results.xls, annotated images.

### IF_GFP_GP100.ijm
- **Purpose:** Aligns and quantifies GFP and GP100 positive cells in serial sections.
- **Features:** Image alignment, tissue/ROI selection, cell segmentation, colocalization.
- **Output:** Quantification tables, annotated images.

### IF_LamininCSA_v2.ijm
- **Purpose:** Quantifies muscle fiber cross-sectional area and nuclei centralization.
- **Features:** Fiber/nuclei segmentation, manual editing, classification.
- **Output:** Results tables, fiber/nuclei masks, annotated images.

### IF_MMP10.ijm
- **Purpose:** Quantifies green intensity in manually selected cells.
- **Features:** Manual cell selection, segmentation, intensity measurement.
- **Output:** QuantificationResults.xls, annotated images.

### IF_MP14.ijm / IF_MP14_2ch.ijm
- **Purpose:** 3D segmentation and quantification of nuclear/cytoplasmic proteins.
- **Features:** Multi-channel segmentation, volume/intensity measurement, shape descriptors.
- **Output:** Total.xls, analyzed images.

### IF_MacrophageClass.ijm
- **Purpose:** Automatic classification of macrophage phenotypes.
- **Features:** Macrophage/phenotype marker segmentation, phenotype quantification.
- **Output:** IF_quantification.xls.

### IF_MANUALCardio_v2.ijm
- **Purpose:** Manual selection and measurement of cardiomyocytes.
- **Features:** Manual ROI, nuclei detection, area/diameter measurement.
- **Output:** [image].xls, analyzed images.

### IF_NanoTrack.ijm
- **Purpose:** Nanoparticle tracking in time-lapse images.
- **Features:** Preprocessing, artifact removal, TrackMate integration.
- **Output:** Track overlays, CSV tracks.

### IF_NETs.ijm
- **Purpose:** Quantifies NETs (neutrophil extracellular traps) in confocal images.
- **Features:** K-means clustering, nuclei/NETs segmentation, cell classification.
- **Output:** Quantification_IF_NETs.xls, overlays.

### IF_Neutrophils_N2.ijm
- **Purpose:** Quantifies neutrophil populations and N2-type neutrophils.
- **Features:** Nuclei/cytoplasm segmentation, marker quantification, ratio calculation.
- **Output:** QuantificationResults.xls.

### IF_Neuron.ijm
- **Purpose:** Quantifies rafe structures in brain IF images.
- **Features:** Manual ROI selection, intensity measurement in regions.
- **Output:** Results.xls.

### IF_Nucleolos.ijm / IF_NucleolosI&S.ijm
- **Purpose:** Quantifies nucleoli intensity and shape in IF confocal images.
- **Features:** Channel selection, nuclei/nucleoli segmentation, shape descriptors.
- **Output:** Quantification_IntensityResults.xls, ShapeDescriptors.xls.

### IF_NuclCyto.ijm / IF_nuclCyto_v3.ijm / IF_NuclCyto_Phenotype.ijm
- **Purpose:** Quantifies nuclear and cytoplasmic IF signal.
- **Features:** Nuclei/cell segmentation, marker quantification in compartments.
- **Output:** QuantificationResults_IF_NuclCyto.xls, QuantificationResutls_IF_NuclCyto_Phenotype.xls.

### IF_PhenotypeQuant.ijm
- **Purpose:** Automatic classification of cell phenotypes (single channel).
- **Features:** Preprocessing, thresholding, area/intensity quantification.
- **Output:** Quantification_[phName].xls.

### IF_Soma_and_axon_size_2D.ijm
- **Purpose:** Quantifies soma and axon size in 2D neuron images.
- **Features:** Manual ROI, soma annotation, prolongation area measurement.
- **Output:** Quantification_Somas_and_Prolongations.xls, analyzed images.

### IF_TrombosM1M2.ijm
- **Purpose:** Quantifies nuclei and cells positive for green/red markers.
- **Features:** Nuclei/cell segmentation, marker quantification, density calculation.
- **Output:** QIF_results.xls, analyzed images.

### IF_Vessels_Platelets.ijm
- **Purpose:** Quantifies vessels and platelets in IF images.
- **Features:** Vessel/platelet segmentation, area/count measurement.
- **Output:** Quantification tables, overlays.

### IF3D_BiofilmQuantification.ijm
- **Purpose:** Volumetric analysis of 3D bacteria biofilm in confocal stacks.
- **Features:** Single file and batch mode; interactive thresholding; quantifies biofilm volume, density, surface area, roughness, and thickness; supports ROI management.
- **Output:** QuantificationResults_IF3D_BiofilmQuantification.xls, segmented images with overlays.

### IF3D_BiofilmQuantification_Cocultivos.ijm
- **Purpose:** Volumetric analysis of 3D cocultured bacteria biofilms with two markers.
- **Features:** Single file and batch mode; interactive thresholding; quantifies total biofilm and individual marker volumes, ratios, surface area, roughness, and thickness.
- **Output:** Results_IF3D_BiofilmQuantification_Colultivos.xls, segmented images with overlays.

### IF3D_BiofilmQuantification_LiveDead.ijm
- **Purpose:** Volumetric analysis of live and dead bacteria in 3D biofilms.
- **Features:** Single file and batch mode; interactive thresholding for live and dead channels; quantifies total, live, and dead biofilm volumes and ratios; slice-wise density analysis.
- **Output:** IF3D_BiofilmQuantification_LiveDead.xls, segmented images for live, dead, and total biofilm.

### IF3D_CellCount.ijm
- **Purpose:** Counts nuclei/cells in 3D confocal stack images.
- **Features:** Single file and batch mode; channel selection; adjustable min/max particle size; 3D segmentation; volume and intensity statistics.
- **Output:** Quantification_IF3D_CellCount.xls, labeled images with overlays.

### IF3D_CellNucleusAlignment.ijm
- **Purpose:** Quantifies 2D morphology and orientation of nuclei in 3D stacks.
- **Features:** Single file mode; user selects DAPI and fiber channels; reference fiber orientation; StarDist segmentation; computes area, aspect ratio, circularity, Feret diameter, and relative angle.
- **Output:** Excel file with morphology/orientation metrics, analyzed images with overlays.

### IF3D_Centriolos.ijm
- **Purpose:** Quantifies centrioles and their integrated intensity in 3D IF stacks.
- **Features:** User selects ROI; processes red channel; computes average and max intensity per slice; detects foci using 3D Objects Counter.
- **Output:** Total.xls with number of foci and intensity metrics, 3D viewer visualization.

### IF3D_Coloc2NuclearProts.ijm
- **Purpose:** 3D colocalization analysis of two nuclear proteins with speckle/foci structures.
- **Features:** Single file and batch mode; channel selection; automatic segmentation; computes number and volume of speckles, colocalization, and ratios per cell.
- **Output:** QuantificationResults_IF3D_Coloc2NuclearProts.xlsx, analyzed images, ROI sets.

### IF3D_FibrinMesh3D.ijm
- **Purpose:** 3D segmentation and quantification of fibrin mesh in confocal images.
- **Features:** User selects number of Z-slices; background subtraction; steerable filtering; ridge detection; BoneJ analysis for volume, density, thickness, and fiber length.
- **Output:** Quantification_FibrinMesh.xls, segmentation images, overlays.

### IF3D_ManguitoRotador.ijm
- **Purpose:** Quantifies nuclei and epigenetic marker signal in 3D stacks of rotator cuff tissue.
- **Features:** Batch mode; channel selection; projection and slice-wise segmentation; computes nuclear volume and average marker intensity.
- **Output:** Quantification_Global.xls, Quantification_IndividualCells.xls, analyzed images.

### IF3D_MicrogliaMarkerColoc.ijm
- **Purpose:** 3D qualitative colocalization of microglia and protein markers in confocal stacks.
- **Features:** Single file and batch mode; channel selection; vessel exclusion; segmentation and quantification of marker volumes and colocalization ratio.
- **Output:** Colocalization_Results.xls, segmented images, overlays.

### IF3D_NeuralFiberColoc.ijm
- **Purpose:** 3D colocalization analysis of neuron fibers and protein markers.
- **Features:** Single file and batch mode; channel selection; thresholding and size filtering; quantifies marker volumes and colocalized volume; saves ROI sets.
- **Output:** Colocalization_Results.xls, analyzed images, ROI sets.

### IF3D_NeuralPhagocytosis.ijm
- **Purpose:** 3D colocalization quantification of neuron and phagocyte markers.
- **Features:** Single file and batch mode; channel selection; thresholding and size filtering; volumetric and surface colocalization analysis.
- **Output:** IF3D_NeuronPhagocytosis (Surface or Volumetric).xls, segmented images.

### IF3D_NuclearDots.ijm
- **Purpose:** Automatic quantification of nuclear 3D structures (foci) per cell.
- **Features:** Single file and batch mode; channel selection; adjustable thresholds and size filters; nuclei and foci segmentation; per-cell foci counting.
- **Output:** QuantifiedRedFOCIs.xls, analyzed images.

### IF3D_NuclCyto.ijm
- **Purpose:** Automatic segmentation and quantification of nuclei and cytoplasm in IF 3D images.
- **Features:** Single file and batch mode; adjustable thresholds; computes volumes and average intensities for nucleus, cytoplasm, and whole cell; percent saturated voxels.
- **Output:** QuantificationResutls_IF3D_NuclCyto.xls, analyzed images.

### IF3D_WholeFieldIntensity.ijm
- **Purpose:** Quantifies protein intensity distribution in IF 3D stacks.
- **Features:** Single file and batch mode; channel selection; computes area, mean, std, min, max intensity; saves projections and segmented images.
- **Output:** ProteinQuantification.xlsx, segmented images.

### IF4D_BiofilmQuantification.ijm
- **Purpose:** Quantification of live/dead bacteria in 4D (time-lapse) confocal images.
- **Features:** Single file and batch mode; interactive thresholding; supports time series and volumetric analysis; computes biofilm volume, density, thickness, and surface area over time.
- **Output:** QuantificationResults_IF3_BiofilmQuantification.xls, segmented images.

### IF4D_ColocLiveInfection.ijm / IF4D_LiveInfection.ijm
- **Purpose:** Quantifies colocalization of lysosome and NP-GFP signals in 4D live infection confocal images.
- **Features:** Single file and batch mode; interactive thresholding; channel selection; computes total and colocalized volumes per frame; saves overlays.
- **Output:** InfectionResults.xls, segmented images with overlays.

### PHC3D_OrganoidCount.ijm
- **Purpose:** Quantification of organoids in phase contrast 3D Z-stack images (Button Device).
- **Features:** Single file and batch mode; user-defined parameters (resolution, min/max organoid size, circularity filter); automated background removal and artifact exclusion; 3D segmentation; connected components labeling and 3D region analysis.
- **Output:** QuantifiedImages.xls (image label, number of organoids, average size, std size); labeled/segmented images in AnalyzedImages folder.

### PHC_MonocyteCount.ijm
- **Purpose:** Quantification of monocytes in brightfield tissue images.
- **Features:** Automatic tissue detection and segmentation; manual ROI editing (add/remove tissue areas); automatic monocyte detection via maxima finding; manual correction of detected monocytes.
- **Output:** Quantification_Monocytes.xls (image label, number of monocytes, tissue area); analyzed images with overlays.

### PHC_ClustersArea.ijm
- **Purpose:** Quantification of clustered cell areas in phase contrast microscopy images.
- **Features:** Single file and batch mode; user-defined parameters (resolution, min cluster size, cluster splitting tolerance); gradient-based segmentation; morphological filtering; background subtraction; watershed for cluster splitting.
- **Output:** Results_PHC_ClusterArea.xls (image label, number of clusters, cluster IDs, area); segmented/annotated images in AnalyzedImages.

### WSI_TRAP.ijm
- **Purpose:** Quantification of positive area in TRAP-stained WSI images.
- **Features:** Manual ROI selection; color thresholding for positive area; area measurement and ratio calculation.
- **Output:** Total.xls (label, total area, positive area, % ratio); analyzed images with overlays.

### WSI_TranswellCells.ijm
- **Purpose:** Quantification of high-intensity stained cells in transwell brightfield images.
- **Features:** Single file and batch mode; user-defined thresholds for tissue and cell segmentation, min cell size; automatic tissue and cell detection.
- **Output:** QuantificationResults_WSI_TransWellCells.xls (label, tissue area, cell area, ratio); analyzed images with overlays.

### WSI_Steatosis.ijm
- **Purpose:** Quantification of steatosis (fat deposits) in WSI images.
- **Features:** Single file and batch mode; user-defined thresholds for tissue and fat, min/max fat size, texture/circularity filters; texture-based separation of fat/glucogen.
- **Output:** QuantificationResults_Steatosis.xls (label, tissue area, steatosis area, ratio); segmented/annotated images.

### WSI_SiriusRedPerivascular.ijm
- **Purpose:** Quantification of Sirius Red IHC in WSI images (perivascular analysis).
- **Features:** Single file mode; interactive thresholding; background correction (global/tissue); color deconvolution for Sirius Red; manual ROI editing; batch mode (commented).
- **Output:** SiriusRed_QuantificationResults.xls (label, tissue area, positive area, ratio); analyzed images, ROI sets.

### WSI_SiriusRedCardio.ijm
- **Purpose:** Quantification of Sirius Red IHC in cardiac WSI images.
- **Features:** Single file mode; interactive thresholding; manual ROI editing; color deconvolution for Sirius Red.
- **Output:** QuantificationResults_SiriusRedCardio.xls (label, tissue area, positive area, ratio); analyzed images, ROI sets.

### WSI_SiriusRed.ijm
- **Purpose:** Quantification of Sirius Red IHC in WSI images.
- **Features:** Single file and batch mode; interactive or automatic workflow; color deconvolution; background compensation; manual ROI editing.
- **Output:** QuantificationResults_SiriusRed.xls (label, tissue area, positive area, ratio); analyzed images, ROI sets.

### WSI_SiriusRed_Manual.ijm
- **Purpose:** Manual quantification of Sirius Red IHC in WSI images.
- **Features:** Single file and batch mode; interactive thresholding; manual ROI editing; color deconvolution.
- **Output:** QuantificationResults_SiriusRed.xls (label, tissue area, positive area, ratio); analyzed images, ROI sets.

### WSI_PAS_Transwell.ijm
- **Purpose:** Quantification of PAS-stained cells in transwell images.
- **Features:** Single file and batch mode; user-defined threshold for PAS-positive segmentation, min cell size; automatic parameter optimization (optional); manual ROI editing.
- **Output:** QuantificationResults_WSI_PAS_Transwell.xls (label, tissue/PAS thresholds, tissue area, PAS area, ratio); analyzed images.

### WSI_NecrosisHE.ijm
- **Purpose:** Quantification of necrosis in H&E-stained WSI images.
- **Features:** User-defined thresholds for tissue, haematoxylin, eosin; manual ROI editing (add/remove tissue/necrosis); color deconvolution for H&E.
- **Output:** NecrosisQuantification.xls (label, tissue area, necrosis area, ratio); analyzed images with overlays.

### WSI_MMPsafranin.ijm
- **Purpose:** Quantification of red safranin-stained area in WSI images.
- **Features:** Manual ROI selection; HSB color thresholding for safranin; area measurement and ratio calculation.
- **Output:** Total.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_LymphTcount.ijm
- **Purpose:** Quantification of CD3+ T lymphocytes in HE+CD3 WSI images.
- **Features:** Automatic tissue/nuclei segmentation; color deconvolution for brown marker; user-defined thresholds and size filters; batch and single file mode.
- **Output:** Total.xls (label, number of cells, number of lymphT cells, tissue area); analyzed images with overlays.

### WSI_LungTissueCD3.ijm
- **Purpose:** Quantification of CD3+ cells in lung WSI images.
- **Features:** Automatic tissue/nuclei segmentation; color deconvolution for brown marker; user-defined thresholds, min % CD3+ for positive cells; batch and single file mode.
- **Output:** Quantification_CD3count.xls (label, number of total cells, number of CD3+ cells, tissue area); analyzed images with overlays.

### WSI_LungNodulesHE.ijm
- **Purpose:** Quantification of lung nodules in H&E-stained WSI images.
- **Features:** Automatic tissue/nodule segmentation; manual ROI editing (delete tissue/nodules); color deconvolution for H&E.
- **Output:** Total.xls (label, tissue area, nodule area, ratio); analyzed images with overlays.

### WSI_LeucoCount.ijm
- **Purpose:** Quantification of CD45+ leucocytes in HE+CD45 WSI images.
- **Features:** Automatic tissue/nuclei segmentation; color deconvolution for brown marker; user-defined thresholds and size filters; batch and single file mode.
- **Output:** Total.xls (label, number of cells, number of leucocytes, tissue area); analyzed images with overlays.

### WSI_EosinIntensity.ijm
- **Purpose:** Quantification of eosin intensity in selected regions of WSI images.
- **Features:** Manual ROI selection (multiple regions); automatic tissue segmentation; color deconvolution for eosin.
- **Output:** EosinQuantification.xls (label, measured tissue area, eosin intensity); analyzed images with overlays.

### WSI_Desmin.ijm
- **Purpose:** Quantification of brown desmin-stained area, removing nonspecific vessel staining.
- **Features:** Automatic tissue/vessel detection; color deconvolution for brown marker; user-defined vessel exclusion size; batch and single file mode.
- **Output:** ResultsCuantificacionDesmina.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_DABintensity_ROIs.ijm
- **Purpose:** Quantification of DAB intensity in manually drawn ROIs.
- **Features:** Manual ROI selection (multiple areas); background subtraction; color deconvolution for DAB; area and intensity measurement.
- **Output:** Results.xls (label, area of analysis, DAB+ area, DAB+ avg intensity); analyzed images with overlays.

### WSI_CD3count.ijm
- **Purpose:** Quantification of CD3+ cells in WSI images.
- **Features:** Automatic tissue/nuclei segmentation; color deconvolution for brown marker; user-defined thresholds, min % CD3+ for positive cells; batch and single file mode.
- **Output:** Quantification_CD3count.xls (label, number of total cells, number of CD3+ cells, tissue area); analyzed images with overlays.

### WSI_CapillaryDAB.ijm
- **Purpose:** Quantification of DAB-stained capillaries in WSI images.
- **Features:** Manual ROI selection for analysis area; automatic tissue/capillary detection; color deconvolution for DAB; manual editing of detected capillaries.
- **Output:** Quantification_capillaries_area.xls (label, analyzed tissue area, capillary area, ratio, number of capillaries); Quantification_capillaries.xls (label, analyzed tissue area, number of capillaries); analyzed images with overlays.

### WSI_BrownDetectionArea.ijm
- **Purpose:** Quantification of brown-stained area in WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds; batch and single file mode.
- **Output:** Total.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Spleen.ijm
- **Purpose:** Quantification of brown-stained area in spleen WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** Resutls_WSI_BrownDetectionArea_Spleen.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Muscle.ijm
- **Purpose:** Quantification of brown-stained area in heart/muscle WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds; batch and single file mode.
- **Output:** Results_WSI_BrownDetectionArea_Muscle.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Lung.ijm
- **Purpose:** Quantification of brown-stained area in lung WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** Results_WSI_BrownDetectionArea_Lung.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Liver.ijm
- **Purpose:** Quantification of brown-stained area in liver WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds, min vessel size; batch and single file mode.
- **Output:** Results_WSI_BrownDetectionArea_Liver.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Heart.ijm
- **Purpose:** Quantification of brown-stained area in heart WSI images.
- **Features:** Automatic tissue and brown marker segmentation; tubeness filtering for tissue; user-defined thresholds; batch and single file mode.
- **Output:** Results_WSI_BrownDetectionArea_Heart.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Brain.ijm
- **Purpose:** Quantification of brown-stained area in brain WSI images.
- **Features:** Automatic tissue and brown marker segmentation; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** Results_WSI_BrownDetectionArea_Brain.xls (label, tissue area, stained area, ratio); analyzed images with overlays.

### WSI_BrownDetectionArea_Brain_NHI_SMI38.ijm
- **Purpose:** Quantification of brown-stained area in brain WSI images (NHI/SMI38).
- **Features:** Automatic tissue and brown marker segmentation; background correction; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** WSI_BrownArea_Brain_Results.xls (label, tissue area, stained area, ratio, background/HE/marker stats); analyzed images with overlays.

### WSI_BrownDetectionArea_Brain_MBP.ijm
- **Purpose:** Quantification of brown-stained area in brain WSI images (MBP).
- **Features:** Automatic tissue and brown marker segmentation; background correction; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** WSI_BrownArea_Brain_Results.xls (label, tissue area, stained area, ratio, background/HE/marker stats); analyzed images with overlays.

### WSI_BrownDetectionArea_Brain_IBA1.ijm
- **Purpose:** Quantification of brown-stained area in brain WSI images (IBA1).
- **Features:** Automatic tissue and brown marker segmentation; background correction; user-defined thresholds, min stained particle size; batch and single file mode.
- **Output:** WSI_BrownArea_Brain_Results.xls (label, tissue area, stained area, ratio, background/HE/marker stats); analyzed images with overlays.

### WF_ClusterArea.ijm
- **Purpose:** Quantification of clustered cell areas in widefield phase contrast microscopy images.
- **Features:** Single file and batch mode; user-defined parameters (resolution, min cluster size); segmentation and area measurement.
- **Output:** Results_PHC_ClusterArea.xls (image label, number of clusters, cluster IDs, area); segmented/annotated images.