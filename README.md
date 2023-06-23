# CrimeMap

**Online Round Task![](Aspose.Words.e3d81a74-2281-4c46-9463-ab835c4dee6f.001.jpeg)**

**iOS Developer | DEV Challenge XIX | Semi Final**

**Content:**

1. [Task description](#_page0_x72.00_y370.88)
1. [Description of input data](#_page1_x72.00_y173.82)

**1<a name="_page0_x72.00_y370.88"></a>. Task description**

Since 2014, the [Center for Civil Liberties](https://ccl.org.ua/en/about-the-ccl/) has been helping to protect people's rights and release from prison military prisoners, including civilians, soldiers who defended their land, and political prisoners who opposed Putin.

Thousands of people have been saved by the Center for Civil Liberties. During the war, the center defused more than 10,000 war crimes committed by the Russian military on the territory of Ukraine.

**Your task.** Developing an iPad (Swift) application that is going to visualize crimes in Ukraine using the provided database, your task is to create a map visualization of the points along with general statistics of the crimes that happened (e.g. number of distinct crimes, total crimes). This project’s idea is to spread the news to the rest of the world about unjustified aggression against the Ukrainian nation. The final application should fill in the following requirements.

Required:

1. The application is loading the points from the provided files.
1. Map should display all the points, you can leverage Apple’s MapKit.
1. Next to the map should be some general statistics about the crimes, and the count of specific crime types.
1. Point aggregation (if you zoom out you should aggregate pins together).
1. There should be a possibility to switch between dates.

Optional: users can select the time period they want to filter to (start/end date).

We will be evaluating the challenge based on working functionality first but you can score additional points if you add some UX flavor to it like animations, please read our evaluation criteria for detailed scoring.

You can use any frameworks or architecture that you want, please provide Readme.MD file with a general (high-level) overview of how / why you did things if it’s non-standard.

2. **Description<a name="_page1_x72.00_y173.82"></a> of input data**

Contents of **[event.json**](https://drive.google.com/file/d/1v4aU2RnUcFL9MlEC7wLikn_fIjrfJlFl/view?usp=sharing)** ([archive link](https://drive.google.com/file/d/1v4aU2RnUcFL9MlEC7wLikn_fIjrfJlFl/view?usp=sharing))**:**

- **from -** start date
- **till -** end date
- **lat, lot -** coordinates
- **event -** id of event type

File **name.json** contains localized names of events listed in **[event.json**](https://drive.google.com/file/d/1v4aU2RnUcFL9MlEC7wLikn_fIjrfJlFl/view?usp=sharing)**

- **qualification -** legal qualification
- **object\_status -** type of object that was attacked
- **affected\_type -** type of harmed people
- **affected\_number -** number of people affected (per episode)

Requirements:

- project should build on Xcode 14.0+.
- language should be Swift.
- target should support the iPad as the main platform.
- minimal iOS version is 15.0.

