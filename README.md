# 🧠 MRI Brain Tumor Segmentation  

This project analyzes MRI brain scans 🧠 to segment cerebral tumors and evaluate their volume.  
The MATLAB script applies various image processing techniques 🎛️ to isolate lesions, refine contours, and compute quantitative results.  
The full project description can be found [here](./Medical_Imaging.pdf).  

---

## 🚀 Project Overview  

Magnetic Resonance Imaging (MRI) is a powerful and non-invasive technique for brain visualization.  
One of the fundamental steps is **image segmentation**, useful for:  
- 🧩 Tissue classification  
- 🎯 Tumor identification  
- 📐 Volume evaluation  
- 🩺 Surgical planning  

This project provides a **workflow for brain tumor segmentation** from MRI volumes using **MATLAB** and the **Image Processing Toolbox**.  

---

## ⚙️ Features  

- 🔍 **Interactive analysis**: supports both **sagittal** and **axial slices**  
- 🎛️ **Noise simulation and filtering**: Gaussian or Salt & Pepper with built-in filters  
- ✂️ **Cropping Tool**: simple selection of the region of interest (ROI)  
- 🎨 **Edge Detection**: Prewitt kernels applied in multiple directions  
- 🖼️ **Lesion isolation**: combination of manual selection and automatic filling  
- 🛠️ **Correction Tool**: manual adjustment of slices with errors  
- 📊 **Quantitative results**: calculation of areas (mm²) and volume (mm³)  

---

## 🧑‍💻 How It Works  

1. **Load the MRI volume**  
   - Provided as a MATLAB file with pixel and volume dimensions.  

2. **Preprocessing**  
   - Optional noise addition (Gaussian / Salt & Pepper).  
   - Noise removal via median or averaging filters.  

3. **Segmentation workflow**  
   - Select the slices containing the tumor.  
   - Crop the region of interest.  
   - Apply edge detection and binarization.  
   - Manually refine lesion boundaries.  

4. **Postprocessing**  
   - Correct remaining errors manually.  
   - Compute **areas (mm²)** and **volume (mm³)** of the tumor.  

---

## 📊 Results  

- The pipeline works well on both clean and noisy images.  
- Variations due to noise are minimal thanks to filtering.  
- Manual correction improves the reliability of the outcome.  

👉 For full details, run on Matlab [Medical Imaging.m](Medical Imaging.m).  

---

## 🛠️ Requirements  

- MATLAB  
- Image Processing Toolbox  
- VolumeViewer App  

---

## 👥 Authors  

- **Guglielmo Bruno** – Politecnico di Milano  
- **Mirko Coggi** – Politecnico di Milano  
- **Antonio Scardino** – Politecnico di Milano  

Developed as an academic project at **Politecnico di Milano**.  
Special thanks to professors and colleagues who supported its completion.  
