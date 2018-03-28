# Collect & Prep Your Data Workshop

This repository contains materials used in the Coffee & Code workshop: Collect & Prep Your Data for Visualization and Analysis.

## Materials

- [Slides](/data-prep/data-workshop.pdf)
- [Data](/data-prep/data)

## Exercise 1 - Visual Analysis (10 minutes)

- Do a [visual analysis of the Information Wanted dataset](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/UNJU3N)
- Consult the [Information Wanted Codebook](/data-prep/info_wanted_codebook.odt)

## Exercise 2 - Data Prep & Cleaning (~20 minutes)

- Launch OpenRefine from your applications and a browser will open
- Download and unzip [datasets](/data-prep/data) to your machine
- Upload sample-info-wanted-dataset.csv to OpenRefine

### OpenRefine Overview 
  - Undo/Redo tab
  - Common transforms
	- leading/trailing whitespace
	- change to upper/lowercase
	- data type
  - Export options
  - Split cells/columns
  - Text Facet & Clustering (useful for analysis)

### Tips & Recipes
1. Trim all leading/trailing whitespace 
  - Use expression: `value.trim()`

2. Remove all punctuation from text in a column
  - Go to Edit cells —> Transform
  - Use expression: `value.replace(/\p{Punct}/,'')`

3. Remove all punctuation at the end of a subject string
  - Go to Edit cells —> Split multi-valued cells —> Split by separator
  - Join multi-valued cells with a different separator
 
4. Find and replace a specific character
  - Go to Edit cells —> Transform
  - Use expression `replace(value, ''insert punctuation here'','''')`

5. Normalizing dates (Transform function)
- If you need to add leading zeros before day
  - Use expression `value.toDate('dd').toString('dd')`
  
- If you need to add leading zeros before month
  - Use expression `value.toDate('MM').toString('MM')`
  
- To modify format of year with “18” or “19” (other century) prefix
  - Use expression `value.toDate('yyyy').toString('18yy')`
  
- To convert abbreviations (month) to numeric date
  - Use expression `value.toDate('MMM-yy').toString('18yy-MM')`
  
- To join the day, month, year into a single column
  - Transpose cells across column into rows
  - Create one column: date
  - Join multi-valued cells and use a hyphen as separator
  - Move columns in order of year/month/date
   - Can also use expression `value.toDate('MM-dd-yyyy').toString('yyyy-MM-dd')`

6. Geocode location data
- Add column by fetching URLs based on on column
- Give your new column a name
- Change throttle delay to 1000 milliseconds 
- Use Expression: 
`"http://nominatim.openstreetmap.org/search?format=json&email=[YOUR_EMAIL_HERE]&app=google-refine&q=" + escape(value, 'url')`
- Split your coordinates into two columns (latitude/longitude)
  - Use expression: `value.parseJson()[0].lat`
  - Repeat for longitude

Visit [OpenRefine Recipes](https://github.com/OpenRefine/OpenRefine/wiki/Recipes) for additional tips

## Suggested Tools
- [OpenRefine](http://openrefine.org/)
- [TAPoR](http://tapor.ca/home)
- [Google Fusion Tables](https://sites.google.com/site/fusiontablestalks/)
- [Voyant](https://voyant-tools.org/)
- [RAWGraphs](https://rawgraphs.io/)
- [Tableau Public](https://public.tableau.com/en-us/s/)

## Suggested Readings

- Owens, [Defining Data for Humanists: Text, Artifact, Information or Evidence?](http://journalofdigitalhumanities.org/1-1/defining-data-for-humanists-by-trevor-owens/)
- Schöch, [JDH: Big? Smart? Clean? Messy? Data in the Humanities](http://journalofdigitalhumanities.org/2-3/big-smart-clean-messy-data-in-the-humanities)
- Rawson and Muñoz, [Against Cleaning](http://curatingmenus.org/articles/against-cleaning)
- The Santa Barbara Statement on [Collections as Data](https://collectionsasdata.github.io/statement/)

## Additional Resources
- [Getty Thesaurus of Geographic Names](http://www.getty.edu/research/tools/vocabularies/tgn/)
- [GPS Coordinates](https://www.gps-coordinates.net/) 
- [OpenRefine Documentation](https://github.com/OpenRefine/OpenRefine/wiki/Documentation-For-Users)
- [OpenRefine Date Functions](https://github.com/OpenRefine/OpenRefine/wiki/GREL-Date-Functions )
- [Cleaning Data with OpenRefine, Programming Historian](http://programminghistorian.org/lessons/cleaning-data-with-openrefine)
