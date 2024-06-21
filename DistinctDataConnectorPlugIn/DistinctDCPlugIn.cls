Class DistinctDataConnectorPlugIn.DistinctDCPlugIn Extends %DeepSee.PlugIn.Distinct
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
    name="Custom DC Distinct" sourceType="mdx"
    caption=""
    >
    <filter name="%cube" displayName="Subject Area"/>
    <filter name="%level" displayName="Level"/>
    <property name="DISTINCT" displayName="Distinct Count" description="Compute the number of distinct values for a given level" />
    </kpi>
}

/// Return an <class>%SQL.StatementResult</class> object that will iterate over the facts used for analysis.
Method %OnGetAnalysisResultSet(Output pRS As %SQL.StatementResult, pSQL As %String) As %Status
{
        // This "UniqueText part is needed to make a unique MDX string for this PlugIn so it does not share other ResultSet objects/cache
        Set tMDX=..%GetPluginMDX()_", 1 as UniqueText"
		set tMDX=$replace(tMDX,"DRILLFACTS","DRILLTHROUGH")
		Set tRS=##class(%DeepSee.ResultSet).%New()
        Do tRS.%PrepareMDX(tMDX)
        Do tRS.%Execute()
        Do tRS.%GetListingResultSet(.pRS)
        // This is used to keep the RS in memory so it is not closed and the underlying listing results are not purged
        set %KeepRSInMemory=tRS
        Quit $$$OK
}

/// This is where we actually do work in the PlugIn.
/// We are given an SQL result set of all the facts included in this
/// cell. We can loop over the facts and exclude doubles from the count
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
 	Set ..%seriesCount = 1
 	Set ..%seriesNames(1) = "Total"
 
	// iterate through result set 
	Set tDistinctValues = 0
	Set n = 0
	
	While (pSQLRS.%Next(.tSC)) {
		If $$$ISERR(tSC) {
			Set tErrMsg = $System.Status.GetErrorText(tSC)
			Quit
		}
		Set n = n + 1

		//Grab the value for this fact
        // NOTE: This line is changed for this Advanced Data Connector Sample
		Set tFactValue = pSQLRS.HomeCity
		
		If $ListValid(tFactValue) {
			// DTB424 - The value is a list of items in a list-based dimension. 
			// Parse this list and count the individual items.
			For ii=1:1:$LL(tFactValue) {
				Set tListValue = $LG(tFactValue,ii)
				If ($G(^||tValues(tListValue))) { /* do nothing */ }
				Else {
			  		//Count distinct value
			  		Set ^||tValues(tListValue) = 1
			  		Set tDistinctValues = tDistinctValues+1
				}
			}
		}
		Else {
			//Test if value is distinct
			If ($G(^||tValues(tFactValue))) { /* do nothing */ }
			Else {
		  		//Count distinct value
		  		Set ^||tValues(tFactValue) = 1
		  		Set tDistinctValues = tDistinctValues+1
			}
		}
		
		// update pct complete
		If (n#100 = 0) {
			Do ..%SetPercentComplete(100*(n/pFactCount))
		}
	}
	Set ..%data(1,"DISTINCT") = tDistinctValues
	Kill ^||tValues
	
	quit $$$OK
}

}
