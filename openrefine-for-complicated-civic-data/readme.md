# OpenRefine for Complicated Civic Data

Written by Brandon T. Locke (CC-BY)

## Overview 
### Civic Data

It is quite common for civic data to be shared in formats that are confusing, ill-formed, or incomplete. There are many reasons for this, including the quirks of their (often proprietary) software, language and coding that may be unfamiliar to people outside of the organization, and that open data is most often an unfunded mandate.

Both of the following datasets come from the [Police Data Initiative](https://www.policedatainitiative.org/), a police-driven project that encourages departments across the United States to make incident-level, machine readable data publicly available. Even within this initiative, each department's dataset is significantly different in terms of structure, information inclusion, and delivery method.

This tutorial will provide instruction on normalizing, correcting, and restructuring two datasets from the initiative using OpenRefine.

[Both datasets can be downloaded here](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/openrefine-workshop-files/lansing-burlington-traffic-stops.zip).

### OpenRefine

[OpenRefine](http://openrefine.org/) (formerly known as GoogleRefine), is a very popular tool for working with unorganized, non-normalized (what some may call "messy") data. OpenRefine accepts TSV, CSV, XLS/XLSX, JSON, XML, RDF as XML, and Google Data formats, though others may be used with extensions. It works by opening into your default browser window, but all of the processing takes place on your machine and your data isn't uploaded anywhere. 

**This tutorial will demonstrate some of the most popular and powerful features of OpenRefine, including geocoding using an API, algorithmic word normalization and correction, time and date manipulation.**

## Burlington, VT Dataset

### Loading the Dataset

- The original [Burlington, VT Traffic Stop Dataset](https://www.burlingtonvt.gov/Police/Data/RawData) is available through the Burlington Police Transparency Portal.
- Open OpenRefine - it should open a window in your default web browser
- Click 'Browse' and locate the Burlington CSV on your hard drive. Then click 'Next.'
- The Configure Parsing Options screen will ask you to confirm a few things. It has made guesses, based on the data, on the type of file, the character encoding and the character that separates columns. Take a look at the data in the top window and make sure everything looks like it's showing up correctly.

![project creation screen](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington1-createproject.png "Creating a Project")

- Name the project "Burlington_Traffic_Stops_2016" and click 'Create Project' in the top right corner.

### Evaluation

![spreadsheet view of the data](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington2-reviewdata.png "Evaluate the table and try to find data that could be formatted better")

The 'Date Issued' column seems to be structured regularly, but the format isn't generally recognized as machine-readable, and the times are on a 12-hr clock instead of a 24-hr clock. 

It's great that this dataset has addresses, but they're not all that helpful for a lot of mapping applications. It would be a lot more useful if those had latitute and longitude instead.

### Reformatting Date and Time

OpenRefine has some fairly simple built-in functionality that will help us convert this 12-hr clock to 24-hr and to make the date machine readable.

This tool won't work on any times that are 12:xx PM, so we'll need to make a quick change on the 170 rows that fall in the noon hour.

- It's always good to make a backup before we start changing things. Click on the triangle next to Date Issued, then hover over Edit Column, then select Add column based on column
- The GREL (General Refine Expression Language) window allows you to make some alterations to the original column values. For now, we just want to copy it so we'll leave it as-is. Leave `value` in the GREL window and change the name to 'orig_Date_Issued' and hit OK
- Click Date Issued > Text filter
- Enter 'PM' to filter out all but the 3,278 records issued in the PM
- Click Date Issued > Edit Cells > Transform
- Enter `value.replace(" 12:"," 00:")` - this will change all times starting with 12 to 00. The inclusion of the space and colon ensures that no months, minutes, or seconds are impacted. Click OK. This should work on 170 cells.

![using the GREL window to change all 12:xx to 00:xx](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington3-replace12.png "")

- On the left side, click 'Remove All' to remove the text filter and bring back both AM and PM rows.
- Click Date Issued > Edit cells > Common Transforms > To Date - this will convert all of the dates into a standard [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.
- You can spot-check Date Issued with orig_Date_Issued to make sure everything is correct. Record #36 takes place at 12:47 PM, and you can see that the conversion worked for those cells we edited.

![data with correctly formatted dates](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington4-datecheck.png "Corrected, machine-readable dates")

### Geocoding
This dataset has the locations of each traffic stop in it, but for many mapping platforms, knowing the street address isn't enough. Luckily, OpenRefine can use Geolocation APIs to find a latitude and longitude for addresses - even if they're just cross-street descriptions like the ones most commonly used in this dataset.

#### Quick Workshop Version

*We'll do a small subset of these traffic stops using Google Maps, which doesn't require a user key to access the geocoder. The downsides of using Google Maps are that they do not allow the data to be used in platforms besides Google Maps, and that they have a limit of 2,500 requests per day. This process is taken from the [OpenRefine Wiki](https://github.com/OpenRefine/OpenRefine/wiki/Geocoding), which also includes instructions on using the Google API in batches to complete an entire datset*

Since there's a limit of 2,500 requests per day and the API takes a bit of time, we'll filter out just two rows to gather latitude and longitude.

- Click Commercial Vehicle > Facet > Text Facet
- Click 'True' to only show the 2 rows that were related to traffic accidents
- Click Location > Edit Column > Add Column by Fetching URLs... and enter this expression: `"http://maps.google.com/maps/api/geocode/json?sensor=false&address=" + escape(value, "url")`

![using the GREL window to access the Google Maps API](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington5-googlegeocode.png "Using the GREL window to access Google Maps API")

- Name the column 'geocodingResponse' and click OK. This will take 20-30 seconds to finish.

![geocoding in progress](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington6-geocodeinprocess.png "Geocoding via the Google Maps API will take a few moments")

- The new 'geocodingResponse' column won't be very clear or useful - it will be the full JSON response with all of the information Google has about that location.
- Click geocodingResponse > Edit Column > Add Column based on this column

![using the GREL window to parse the Google Maps API](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington7-parsegeocode.png "You can use GREL to parse the Google Maps API and get only the information you want")

- Enter `with(value.parseJson().results[0].geometry.location, pair, pair.lat +", " + pair.lng)` and call the new column 'latlng.' Hit OK. This will parse the JSON and correctly format the latitute and longitude in the neew column.
- You can delete the 'geocodingResponse' column (Edit Column > Remove This Column) after you have already extracted the lat/lng coordinates.

#### Full Development 
*Note: this will take an hour or two to process fully, so it's a good idea to set it up to run overnight*

- Get a MapQuest API Key from the [MapQuest Developer Site](https://developer.mapquest.com/) - click the 'Get your Free API Key' button on the front page and fill out the information.
- Once you have an API key, Location > Edit Column > Add Column by Fetching URLs... and enter this expression: `'http://open.mapquestapi.com/nominatim/v1/search.php?' + 'key=YOUR KEY&' + 'format=json&' + 'q=' + escape(value, 'url')` **Note: be sure to add your own API key in the above expression where it says `*YOUR KEY*`**
- Name the column 'geocodingResponse' and click OK. This will take quite some time to finish.
- The new 'geocodingResponse' column won't be very clear or useful - it will be the full JSON response with all of the information Google has about that location.
- Click geocodingResponse > Edit Column > Add Column based on this column
- Enter `with(value.parseJson().resourceSets[0].resources[0].point.coordinates, pair, pair[0] +", " + pair[1])` and call the new column 'latlng.' Hit OK. This will parse the JSON and correctly format the latitute and longitude in the neew column.
- You should see that the resulting column has the lattitude and longitude for the address or cross streets.

### Correcting Typos and Merging Terms
One of the most tedious parts of data cleaning is finding the typos and mistakes in the data, and similarly, finding multiple terms that are essentially the same or are intended to be the same, and merging them together.

One good way to find typos or categories you can collapse is by doing text facets that show you the composition of the column. *You can find more information about the clustering algorithms in the [OpenRefine wiki](https://github.com/OpenRefine/OpenRefine/wiki/Clustering-In-Depth).*

![all of the city names in the dataset viewed via text facet](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington8-cityfacet.png "Using the Text Facet feature to view all unique City names")

- Click on City > Facet > Text Facet. You should see a number of terms that can probably be collapsed and altered, such as Burlignton > Burlington, Burlington VT > Burlington, and Essex Junction > Essex Jct.
- Click on the `x` to close the City facet.
- Click on City > Edit Cells > Cluster and edit...
- The first one uses the Key Collision method. Here you should be able to correct S Burlington & S. Burlington into one. Check the 'Merge?' checkbox, then click on 'Merge Selected & Re-Cluster.'

![clustering feature to find likely candidates for merging](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/burlington9-citycluster.png "Clustering finds likely candidates for merging")

- Change the method to 'nearest neighbor', and then set the Radius at 3.0. We'll grow this progressively higher to cast a wider net.
- There are a number of different ways people have entered S/So/South Burlington, lets take all of those and change them to 'South Burlington'. Type in the new cell value in the right, and check the boxes that look like they should be South Burlington. Be careful not to re-cluster the South Burlingtons with Burlington. 
- Work through a few rounds of this, increasing the Radius and correcting the cells that appear to be incorrect. (Tip - there are several that have 05401 in them - they're likely referring to Burlington proper by its zip code.)
- Clustering is really helpful, but doesn't always solve every problem. Close the cluster screen, and go back to Text Facets.
- There are still a few incorrect versions of Burlington left. You can hover over all of the Facets and click on 'edit' on the right to edit all instances of the cluster.
- Close the 'City' Text Facet and open up a Text Facet on the 'Race' column.
- Here we can see a few entries (B=Black, W=White) that didn't follow the standard input. We can edit them here in the Facet. You may also want to enter 'Null' in place of the blank ones, or change blank to 'Unknown'.

### Saving and Exporting
In the top right corner, you can click on 'Export' and save the data in a number of different formats, including csv and HTML tables.

You may also want to export the entire project. This is useful if you want to share the project with others, or if you want to continue working on a different machine. It's also useful for transparency and documentation, as every change you've made is documented (and reversible).

## Lansing, MI Traffic Stops

### Loading the Dataset

- The original [Lansing, MI Traffic Stop Dataset](https://data-lansing.opendata.arcgis.com/datasets/986d9c96ee03442f85c540f0e4a494b1_0) is available through the Lansing Open Data portal.
- Open OpenRefine - it should open a window in your default web browser (if it's already open, you can click 'Open' at the top to start a new project)
- OpenRefine allows you to upload data from a number of places; by default you can upload data from your computer
- Click 'Browse' and locate the Lansing CSV on your hard drive. Then click 'Next.'
- The Configure Parsing Options screen will ask you to confirm a few things. It has made guesses, based on the data, on the type of file, the character encoding and the character that separates columns. Take a look at the data in the top window and make sure everything looks like it's showing up correctly.
- Click 'Create Project' in the top right corner.

### Evaluation

Take a look at the data and see what types of questions you can ask of it. You may also notice a few formatting or data issues that raise some flags. At the top of the screen, you can set OpenRefine to show you 50 rows at a time so that you can get a better view.

![spreadsheet view of the data](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing1-reviewdata.png "Evaluate the table and try to find data that could be formatted better")

The time and date information in this dataset immediately jumps out as a concern. There are three columns that express the time and date — a 'Time' column with date and time formatted in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601), an 'AM_PM' column, and a 'Date' column. Even more troubling, the 'Time' and 'Date' columns contradict each other. 

The 'Time' column has seemingly automatically added the upload date to every time - each row in the dataset has the same date in the time column. We'll want to swap out the date in the 'Time' column for the date in the 'Date' column. To make analysis of the time and date easier, we'll also want to convert the 12 hr time to 24 hr time using a combination of the 'Time' and 'AM_PM' column.

### Duplicate Original Data

Before we change too much, we should duplicate the columns so that we can check our work. To do this:

- Click on the triangle near the 'AM_PM' column header
- Scroll down to 'Edit Column' and then select 'Add column based on this column'
- Name the new column 'orig_AM_PM'
- The GREL (General Refine Expression Language) box allows you to make some alterations to the original column values. For now, we just want to copy it so we'll leave it as-is.
- Click OK
- Repeat this with the 'Time' column: Click on the triangle near Time > Edit Column > Add column based on this column.
- Call the new column 'orig_Time' and click ok.
- Date > Edit Column > Add column based on this column. Name it 'orig_Date'
- Note: If you find that the duplicates get in the way, you can click on the triangle, go to 'Edit Column' and see options to move columns to the right or left or all the way to the beginning or end.

### Normalizing Date Format

If you scroll down the date column, you'll see that they're almost all formatted YY/MM/DD, but there are several that are formatted MM/DD/YYYY. We can regularize these fairly easily, and we can also be confident in our accuracy since they are uniform in using four characters (YYYY) in the latter format. We also know that all of these traffic stops occurred between February 12, 2016 and February 11, 2017, so we can check ourselves there.

Based on the regular use of YYYY as opposed to YY, we can easily filter these out by searching for the occurrences of 2016 and 2017, then change them to YY/MM/DD:

- Click on the triangle near 'Date,' then select 'Text filter'
- We can use a fairly simple regular expression to find all of the years that used four characters
- Type `201[0-9]` to just select the dates that use four characters. Be sure to also click 'regular expression' so that it's not looking for a literal match
- Any transformations we make now will only impact these 13 rows that match

![using a regular expression in the text filter](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing2-normalizedates.png "Using a regular expression to find all dates with a four character year")

- Click on Date > Edit Cells > Transform. 

![GREL transformation of date order](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing3-normalizedates2.png "Rearranging the date information using date functions")

- Type `toString(toDate(value),"YY/MM/dd")` This will convert the value from a string format to a date format, rearrange it to the format we want, and then convert it back to a string, so that it matches the rest of our dates. 
- Click OK to make the changes and return to the data screen
- On the left side, click 'remove all' to remove the filter and check the data visible in open refine.
- Go back to the 'Date' column, and Transform again. Then type `"20"+value` to make all dates YYYY/MM/dd
- Let's format the date so that it's a string that matches the ISO 8601 format. Click on the triangle by 'Date,' then 'Transform,' and type `value.replace("/","-")`. This will take all `/`s and replace them with `-`s.

![reviewing the normalized dates](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing4-datescorrected.png "All of the dates are now formatted to YYYY/MM/DD")

### Separate the Time of the Stop
The 'Time' column includes the incorrect date and the correct time, with a T in-between.

- Click on Time > Edit Column > Split Column into Several Columns
- Type `T` in the separator field, then click ok. You now have Time 1, which is just the date, and Time 2, which is just the time.

![time column divded into two colmumns - a date and a time](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing5-splitdatetime.png "Two 'Time' columns: one with the incorrect date, and one with the correct time")

- Go ahead and delete Time 1 (Time 1 > Edit column > Remove this column)

### Append Correct Date with Time
- Click Date > Edit column > Add column based on this column.
- Type in `cells["Date"].value + "T" + cells["Time 2"].value` and name it "DateTime"

- You should now have the dates in ISO 8601 format, but since it's still on a 12 hr clock, many of the times are incorrect.

### Converting 12 hr time to 24 hr time
This dataset has a column with am/pm and a time format that is meant for a 24 hr clock. To correct this, we'll need to facet out all of the PM times and then add 12 to the hours. Before we do this, we do have one other small, but important step. With the 24 hr format, something that happens just after midnight will look like it happened just after noon. We'll need to do a special change to convert 12:xx AM to 00:xx AM. We'll also have an issue with things happening just after noon appearing to happen at 24:xx PM.

To convert all 12:xx to 00:xx:

- Click on DateTime > Edit Cells > Transform. This will give us a space to use GREL (General Refine Expression Language) to filter out just the information we want to filter. The current time format has a date followed by a T followed by the time. We can use the T to make sure we're not replacing 12 when it appears in a date or in the minute portion of a time.

- Type `value.replace("T12", "T00")`, then click OK.

![GREL screen to replace T12 with T00](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing6-fix12.png "Replacing all 12:xx times with 00:xx")

Right now, Open Refine sees the 'DateTime' column as a string, not a date. Open Refine has a built-in feature to alter data that it recognizes as dates, but before we do that, we have to make a quick adjustment. We'll need to remove the Z at the end of the time — OpenRefine will adjust the time if the Z is there. (Z is intended to signify that this is UTC - though there's no indication that this is correct - it's much more likely to be in Eastern Standard/Daylight time.)

- Click on DateTime > Edit Cells > Transform
- Type in `value.replace("Z","")` to replace all instances of 'Z' with nothing. Then click OK
- Click on DateTime > Edit Cells > Common transforms > To date. This should successfully transform all 6187 rows, and the data should appear green now.

![DateTime column is now green](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing7-timeformatted.png "If a column is recognized as a date format, it will be green")

Now that this is fixed, we can filter out the PM dates to work with:

- Click on AM_PM > Text filter
- Type in 'PM'. We should see only PM records on the screen
- Click on DateTime > Edit cells > Transform
- In the GREL window, type: `value.inc(12,'hours')` This [function](https://github.com/OpenRefine/OpenRefine/wiki/GREL-Date-Functions#incdate-d-number-value-string-unit) will understand properly formatted dates and allow us to add 12 hours to every time.

![GREL window to increase all PM times by 12 hrs](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing8-convertto24hr.png "Converting to a 24 hour clock by adding 12 hours to all PM rows")

- Click 'Remove All' to clear the filter

Double-check DateTime against the original times and dates to make sure that we've done this correctly. If so, we can remove 'AM_PM,' 'Time 2,', and 'Date.' 

![converted times alongside original times](https://github.com/endangereddataweek/resources/blob/master/openrefine-for-complicated-civic-data/img/lansing9-finalresults.png "Check the DateTime row against the old time columns")

One note: This time is still technically incorrect. These are all in local time, though the use of Z indicates that it's in UTC.

### Saving and Exporting
In the top right corner, you can click on 'Export' and save the data in a number of different formats, including csv and HTML tables.

You may also want to export the entire project. This is useful if you want to share the project with others, or if you want to continue working on a different machine. It's also useful for transparency and documentation, as every change you've made is documented (and reversible).

## Additional OpenRefine Resources
- [OpenRefine Wiki](https://github.com/OpenRefine/OpenRefine/wiki)
- [OpenRefine Recipes](https://github.com/OpenRefine/OpenRefine/wiki/Recipes)
- [Cleaning Data with OpenRefine](https://libjohn.github.io/openrefine/)
- [Fetching and Parsing Data from the Web with OpenRefine](https://programminghistorian.org/lessons/fetch-and-parse-data-with-openrefine)

