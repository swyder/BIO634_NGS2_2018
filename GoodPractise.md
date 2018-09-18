## Golden Rules of bioinformatics

based on Leigthon Pritchard and Peter Cock's [Introduction to Bionformatics Tools](http://de.slideshare.net/leightonp/golden-rules-of-bioinformatics)


### Rule 1
- No-one knows everything about everything - talk to people
  local bioinformaticians, mailing lists, forums, Twitter, etc.
- Keep learning - there are lots of resources
- No method works best for all data 
- The worst errors are silent - share worries, problems, etc
- Share expertise (see first item)

### Rule 2
- Always inspect the raw data (trends, outliers, clustering)
- What is the question? Can the data answer it?
- Communicate with data collectors! (don't be afraid of pedantry)
 - You need to understand the experiment to analyse it
 - Be wary of block effects (experimenter, time, batch, etc.)

### Rule 3
- Do not trust the software: it is not an authority
  - Software does not distinguish meaningful from meaningless data
  - Software has bugs
  - Algorithms have assumptions & conditions
  - Some problems are inherently hard, or even insoluble
- You must understand the analysis/algorithm
- Always sanity test
- Test output for robustness of parameter choice

see also [The dangers of default parameters](http://www.acgt.me/blog/2015/4/27/the-dangers-of-default-parameters-in-bioinformatics-lessons-from-bowtie-and-tophat)

### Rule 4
- Everyone has expectations of their data/experiment
  - Beware cognitive errors, such as confirmation bias!
- Think statistically!
  - Large data sets can be counterintuitive and appear to confirm a
   large number of contradictory hypotheses
  - Always account for multiple testing
  - Avoid "data dredging"
- Use test-driven development of analyses and code
  - Use examples that pass *and* fail


## Short version
- Always communicate!
  - worst errors are silent
- Don't trust the data
  - formatting/validation/category errors - check!
  - suitability for scientific question
- Don't trust the software
  - Software is not an authority
  - always benchmark, always validate
- Don't trust yourself
  - beware confirmation bias
  - think statistically
  - biological "stories" can be constructed from nonsense


