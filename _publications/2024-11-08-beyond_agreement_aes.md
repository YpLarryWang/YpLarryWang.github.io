---
title: "Beyond Agreement: Diagnosing the Rationale Alignment of Automated Essay Scoring Methods based on Linguistically-informed Counterfactuals"
collection: publications
permalink: /publication/2024-11-08-beyond_agreement_aes
excerpt: 'We propose a counterfactual intervention method using Large Language Models (LLMs) to reveal that, in automated essay scoring, while BERT-like models focus on sentence-level features, LLMs align more comprehensively with scoring rubrics by emphasizing conventions, accuracy, language complexity, and organization. The source code and data of this paper is available at [GitHub](https://github.com/YpLarryWang/beyond-agreement-aes-2024).'
date: 2024-11-08
venue: 'ACL Anthology: Findings of EMNLP'
slidesurl: 'https://drive.google.com/file/d/1t9jSPJVNJMXSfXD5MwwQ-4GSGV4Gg8dS/view?usp=drive_link'
paperurl: 'https://aclanthology.org/2024.findings-emnlp.520.pdf'
citation: 'Yupei Wang, Renfen Hu, and Zhe Zhao. 2024. Beyond Agreement: Diagnosing the Rationale Alignment of Automated Essay Scoring Methods based on Linguistically-informed Counterfactuals. In Findings of the Association for Computational Linguistics: EMNLP 2024, pages 8906–8925, Miami, Florida, USA. Association for Computational Linguistics.'
---

While current Automated Essay Scoring (AES) methods demonstrate high scoring agreement with human raters, their decision-making mechanisms are not fully understood. Our proposed method, using counterfactual intervention assisted by Large Language Models (LLMs), reveals that BERT-like models primarily focus on sentence-level features, whereas LLMs such as GPT-3.5, GPT-4 and Llama-3 are sensitive to conventions & accuracy, language complexity, and organization, indicating a more comprehensive rationale alignment with scoring rubrics. Moreover, LLMs can discern counterfactual interventions when giving feedback on essays. Our approach improves understanding of neural AES methods and can also apply to other domains seeking transparency in model-driven decisions.

The source code of the project is available at [GitHub](https://github.com/YpLarryWang/beyond-agreement-aes-2024).