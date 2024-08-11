---
title: "L2C-Rater: ML-Based Automated Essay Scoring Algorithm Leveraging Linguistic Features"
excerpt: "L2C-Rater is an automated essay scoring tool that leverages 90 linguistic features and ordinal logistic regression to accurately evaluate Chinese as a second language (L2) essays, providing a robust, interpretable solution for language learners and educators.<br/><img src='/images/l2c_rater_demo.png'>"
collection: portfolio
---

***Yupei Wang** and Renfen Hu*

As the demand for learning Chinese as a second language (L2) continues to grow, we've developed L2C-Rater, an innovative automated essay scoring (AES) tool designed specifically for Chinese L2 essays. Our solution tackles the challenge of adapting to various essay prompts while maintaining high accuracy.

Key Features:
1. Robust Linguistic Analysis: We've engineered 90 distinct linguistic features that assess both language complexity and correctness.
2. Appropriate ML Model: Our Ordinal Logistic Regression model is specifically chosen to match our dataset's ordinal score levels, ensuring accurate and consistent essay evaluation.
3. High Performance: L2C-Rater achieves impressive results:
   - Quadratic Weighted Kappa (QWK): 0.714
   - Root Mean Square Error (RMSE): 1.516
   - Pearson Correlation: 0.734
4. Interpretability: Using a simple linear model, we provide clear insights into how each linguistic feature contributes to the final score.
5. Feedback Generation: The tool's interpretable nature opens up possibilities for providing detailed writing feedback to users.

L2C-Rater sets a new benchmark in Chinese L2 AES technology, offering a powerful, adaptable, and user-friendly solution for language learners and educators alike. Our approach not only scores essays accurately but also paves the way for personalized learning experiences in Chinese language education.

This project resulted in a paper titled "*[A Prompt-Independent and Interpretable Automated Essay Scoring Method for Chinese Second Language Writing](https://aclanthology.org/2021.ccl-1.107/)*" that was presented at the China National Conference on Chinese Computational Linguistics in August 2021, and published in the *Lecture Notes in Artificial Intelligence*.

The source code of the project is available at [GitHub](https://github.com/iris2hu/L2C-rater), and a demo of the project is available at [Demo](https://l2c.shenshen.wiki/).