.TS H
.TE

.TL
Project Proposal: Atmospheric Transparency and Image Quality Evaluation using WiFeS Autoguiding Camera Images
29 Jan - 17 Feb 2024

.SH
PROJECT DESCRIPTION
.PP
The project aims to develop a methodology and corresponding codebase capable of analysing acquisition images captured by the WiFeS autoguiding camera at the 2.3-meter telescope. These images, primarily used for target acquisition, present a unique opportunity to assess atmospheric conditions at the exposure's initiation. By evaluating the atmospheric transparency and image quality, or "seeing," the project seeks to contribute valuable insights for observational astronomy, enhancing the understanding and interpretation of celestial phenomena.

.SH
OBJECTIVES
.PP
The project's primary objectives include:
.RS
.IP \(bu
Determining atmospheric transparency at the time of exposure.
.IP \(bu
Evaluating the image quality or "seeing" at exposure commencement.
.IP \(bu
Developing a robust codebase for consistent analysis across different data sets.
.RE


Text

.PSPIC figure.eps


.SH METHODOLOGY
.PP

.IP \(bu
\&\fBRun an object finder on the images:\fR Utilize a Python version of the SExtractor software (https://sep.readthedocs.io/en/v1.1.x/) to identify celestial bodies within the acquisition images. This process will involve parsing and leveraging image metadata such as FILTER, EXPTIME, MJD-OBS, AIRMASS, RA, DEC, TELPAN, CRPIX1, CRPIX2, CD1_1, CD1_2, CD2_1, and CD2_2.
.IP \(bu
\&\fBCross match the object catalogue with an external catalogue:\fR Employ the astropy coordinate package (https://docs.astropy.org/en/stable/coordinates/index.html) to cross-reference identified objects with the GAIA and UCAC catalogues, allowing for a refined assessment of the images.
.IP \(bu
\&\fBDetermine the image quality:\fR Analyze the stars captured within the images to assess the image quality or "seeing." The methodology will focus on designing an algorithm that is both efficient and resilient to outlier data.
.IP \(bu
\&\fBDetermine the ZP (Zero Point) taking into account the exposure time and the filter used:\fR It is crucial to account for potential discrepancies between the filter curve of the acquisition image and those of the external catalogues. This step involves making necessary corrections to ensure accurate measurement of the atmospheric transparency and the image quality.
.RE

.SH EXPECTED OUTCOMES
.PP
Upon successful implementation of the proposed methodology, the project is expected to yield:
.RS
.IP \(bu
A robust codebase capable of efficiently processing acquisition images to determine atmospheric transparency and image quality.
.IP \(bu
A comprehensive dataset of processed images accompanied by metadata including but not limited to transparency measures, image quality assessments, and cross-matched celestial object identifiers.
.IP \(bu
A final report detailing the methodology, challenges encountered, solutions implemented, and an analysis of the findings.
.RE

.SH TIMELINE
.PP
The project is anticipated to follow a 6-month timeline, structured as follows:
.RS
.IP \(bu
Month 1: Project initiation, literature review, and familiarization with the datasets.
.IP \(bu
Month 2-3: Development of the object finding and catalog cross-matching code.
.IP \(bu
Month 4: Implementation of the image quality and transparency determination algorithms.
.IP \(bu
Month 5: Testing and refining the codebase with various datasets to ensure robustness and accuracy.
.IP \(bu
Month 6: Analysis of results, preparation of the final report, and dissemination of findings through a presentation.
.RE

.SH DELIVERABLES
.PP
By the conclusion of the project, the following deliverables are expected:
.RS
.IP \(bu
A fully functional codebase, documented and accessible on GitHub or a similar platform, for determining atmospheric transparency and image quality using acquisition images.
.IP \(bu
A dataset comprising analyzed images, metadata, and results.
.IP \(bu
A comprehensive final report detailing the project methodology, findings, and recommendations for future research.
.IP \(bu
A presentation summarizing the project outcomes and its implications for observational astronomy.
.RE

.SH BUDGET
.PP
A detailed budget will be prepared, considering necessary resources such as:
.RS
.IP \(bu
Computational resources for data processing and analysis.
.IP \(bu
Access to external catalogues and databases.
.IP \(bu
Personnel costs for the research team for the duration of the project.
.RE

.SH CONCLUSION
.PP
This project presents an invaluable opportunity to leverage existing acquisition images from the WiFeS autoguiding camera to enhance our understanding of atmospheric conditions and their impact on astronomical observations. Through the development of a specialized codebase, this initiative aims to systematically assess atmospheric transparency and image quality, contributing significantly to the field of observational astronomy. With a structured methodology, clear objectives, and a comprehensive six-month timeline, the project is well-positioned to achieve its goals, yielding insights that could improve the accuracy and efficiency of astronomical research.

.SH ACKNOWLEDGEMENTS
.PP
We would like to extend our gratitude to the 2.3-metre telescope team for providing access to the acquisition images and to the supervisors and advisors whose expert guidance will be invaluable throughout the duration of this project. Additionally, we acknowledge the support of the astronomical community in offering external catalogues and software tools essential for the project's success.

.SH CONTACT INFORMATION
.PP
For further information on the project, its methodology, or potential collaboration opportunities, please contact:
.RS
.IP \(bu
Project Lead: [Project Lead's Name]
.IP \(bu
Email: [Project Lead's Email]
.IP \(bu
Institution: [Affiliated Institution/Organization]
.RE

.SH DOCUMENT INFORMATION
.PP
This document was prepared using the Groff typesetting system and adheres to the standards and formatting guidelines for project proposals within the astronomical community.

.PP
Version: 1.0

.PP
Date: March 2023

.PP
Document Status: Draft Proposal

.SH END OF DOCUMENT
