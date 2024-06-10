This example builds on top of the "ConnectorCube" example from Samples-BI
Data Connector Class: BI.Model.ConnectorExample
Cube Class: BI.Model.ConnectorCube

What this example solves:
If you try and use the built in Distinct PlugIn, with a Data Connector, you get the following:
SAMPLES>do $system.DeepSee.Shell()
DeepSee Command Line Shell
----------------------------------------------------
Enter q to quit, ? for help.
>> WITH  MEMBER [MEASURES].[DistinctCities] AS '%KPI("%DeepSee.Distinct","DISTINCT",1,"%level","[HomeD].[H1].[City]","%CONTEXT")' SELECT [MEASURES].[DISTINCTCITIES] ON 0,NON EMPTY [AgeD].[H1].[Age].Members ON 1 FROM [CONNECTORCUBE]
Results pending...
                            DistinctCities
  1 0                    ERROR #5540: SQLCODE: -51 Message:  An SQL statement expected, { found [sqlact+13^%SYS.DynamicStatement:SAMPLES]

This is in contrast to running the same query against the standard Patients Cube:
>> WITH  MEMBER [MEASURES].[DistinctCities] AS '%KPI("%DeepSee.Distinct","DISTINCT",1,"%level","[HomeD].[H1].[City]","%CONTEXT")' SELECT [MEASURES].[DISTINCTCITIES] ON 0,NON EMPTY [AgeD].[H1].[Age].Members ON 1 FROM [Patients] 
Results pending...
                            DistinctCities
  1 0                                     9
  ...

To work around this error, we need a custom version of the Distinct PlugIn that overrides some of the default dynamic aspects of the standard Distinct PlugIn.

The items we need to override are:
KPI Name
%OnGetAnalysisResultSet
%OnCompute
** See code in DistinctDataConnectorPlugIn.DistinctDCPlugIn **

After implementing these changes, we can run the following and get results:
>> WITH  MEMBER [MEASURES].[DistinctCities] AS '%KPI("Custom DC Distinct","DISTINCT",1,"%level","[HomeD].[H1].[City]","%CONTEXT")' SELECT [MEASURES].[DISTINCTCITIES] ON 0,NON EMPTY [AgeD].[H1].[Age].Members ON 1 FROM [CONNECTORCUBE]
Results pending...
                            DistinctCities
  1 0                                     9
  ...

