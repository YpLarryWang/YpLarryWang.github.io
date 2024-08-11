---
title: "A counterfactual-based Diagnosing Method for Neural-based Automated Essay Assessment Models"
excerpt: "This project introduces a model-agnostic diagnostic method using diverse counterfactual interventions to interpret neural-based Automated Essay Scoring models, revealing their decision-making processes and alignment with human scoring rubrics, while offering potential applications across multiple AI domains.

<br/><img src='/images/rational_alignment_paper_diagram_20240811.png'>"
collection: portfolio
---

***Yupei Wang**, Renfen Hu, and Zhe Zhao*

As Automated Essay Scoring (AES) systems become increasingly prevalent in education, understanding their decision-making processes is crucial. Therefore, we introduces a novel approach to diagnose and interpret neural-based AES models using counterfactual interventions powered by Large Language Models (LLMs).

Key Features:
1. Diverse Counterfactual Generation: Eight types of counterfactuals, including three LLM-based (using GPT-4) and five rule-based interventions, providing a comprehensive set of test cases.

2. Comprehensive Model Evaluation: Testing both BERT-like models (BERT, RoBERTa, DeBERTa) and LLMs (GPT-3.5, GPT-4, Llama-3) using the generated counterfactuals to reveal their scoring mechanisms.

3. Alignment Analysis: Assessing how different models align with human-designed scoring criteria through their responses to counterfactual interventions.

4. Feedback Discernment Test: Evaluating LLMs' ability to discern counterfactual interventions by comparing their feedback on original and modified essay samples.

5. Model-Agnostic and Extensible Approach: Operating on a sample level, our method is model-agnostic, making it highly adaptable for diagnosing decision-making processes in various AI models across different domains requiring transparency and interpretability.

Key Findings:
- BERT-like Models: Primarily focus on sentence-level features.
- LLMs (GPT-3.5, GPT-4, Llama-3): Demonstrate sensitivity to conventions & accuracy, language complexity, and organization, aligning more closely with comprehensive scoring rubrics.
- Feedback Mechanism: LLMs can effectively discern and explain the impact of counterfactual interventions on essay quality.

Our proposed method enhances the understanding of neural AES methods, offering valuable insights for educators, AI researchers, and policymakers seeking to implement fair and interpretable automated assessment systems.