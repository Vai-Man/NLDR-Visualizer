# NLDR-Visualizer  

This repository contains three tests demonstrating **non-linear dimensionality reduction (NLDR)** techniques through interactive visualizations. Each test is in its respective folder, and a **Gallery** subfolder holds visual representations (such as screenshots or GIFs) of the results.  

## Easy Test: Linked Brushing with t-SNE (`easy-test/`)  

This test applies **t-SNE** to reduce the dimensionality of the Palmer Penguins dataset and links it to the original feature space using **linked brushing**. Selecting points in one view highlights them in the other, helping to understand how species are distributed and how clusters form.  

## Medium Test: Comparing Grand Tour and Little Tour (`medium-test/`)  

This test implements a **Shiny application** that compares the **Grand Tour**, which explores all possible projections, and the **Little Tour**, which follows a constrained path. **Linked brushing** allows users to track how points move between projections, revealing structural relationships in high-dimensional data.  

## Hard Test: Interactive t-SNE Shiny Application (`hard-test/`)  

This test builds an interactive **Shiny application** for **t-SNE projections**, where users can adjust **perplexity, learning rate, and iteration count** to see how different parameter choices affect the visualization. Users can select specific features for analysis, updating the plot dynamically.  
