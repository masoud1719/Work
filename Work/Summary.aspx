<%@ Page Language="C#" %>
<%@ Register Assembly="Ext.Net" Namespace="Ext.Net" TagPrefix="ext" %>
<%@ Import Namespace="OfficeOpenXml.Core.ExcelPackage" %>
<%@ Import Namespace="OfficeOpenXml.Drawing.Chart.Style" %>
<%@ Import Namespace="Ext.Net.Utilities" %>
<%@ Import Namespace="OfficeOpenXml.Drawing" %>
<%@ Import Namespace="OfficeOpenXml.Drawing.Chart" %>
<%@ Import Namespace="Work.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Xml.Xsl" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%-- <%@ Import Namespace="ICDMS" %> --%>
<%-- <%@ Import Namespace="System.Windows.Forms" %> --%>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Microsoft.SolverFoundation.Services" %>
<%@ Import Namespace="t=Microsoft.SolverFoundation.Services" %>


<script runat="server">

    public List<double> depths;
    public List<double> calculateSwiList;
    public List<double> calculatePcList;
    public List<double> calculatehcList;

    public string comp_data1_str;
    public string resSystem;
    public string labSystem;
    public double oilWaterContact;
    public double oilDensity;
    public double waterDensity;



    protected void Page_Load(object sender, EventArgs e)
    {

        if (!X.IsAjaxRequest)
        {
            //this.Chart1.GetStore().DataSource = this.GetData();

        }
        comp_data1_str = Request["comp_data1"];
        resSystem = getResSystem(Request["resSystem"]);
        labSystem = getLabSystem(Request["labSystem"]);
        oilWaterContact = Double.Parse(Request["oilWaterContact"]);
        oilDensity = Double.Parse(Request["oilDensity"]);
        waterDensity =Double.Parse( Request["waterDensity"]);
        depths = new List<double>();
        calculateSwiList = new List<double>();
        calculatePcList = new List<double>();
        calculatehcList = new List<double>();
        COMP_Calculation(comp_data1_str);

        Comp_Summary3_Store.DataSource = get_Data();
    }

    private object get_Data()
    {
        var data = new List<object>();
        for (int i = 0; i < depths.Count; i++)
        {
            data.Add(new { depth = depths[i], calculatedSwi = calculateSwiList[i], calculatedPc = calculatePcList[i], calculatedhc = calculatehcList[i] });
        }
        return data;
    }

    private string getResSystem(String resSys)
    {
        if (resSys.ToLower().Equals("oil/water") || resSys.ToLower().Equals("ow"))
        {
            return "OW";
        }
        else
        {
            return "GW";
        }
    }

    private string getLabSystem(String labSys)
    {
        if (labSys.ToLower().Equals("oil/water") || labSys.ToLower().Equals("ow"))
        {
            return "OW";
        } else if (labSys.ToLower().Equals("air/water") || labSys.ToLower().Equals("aw"))
        {
            return "AW";
        }  else if (labSys.ToLower().Equals("air/mercury") || labSys.ToLower().Equals("am"))
        {
            return "AM";
        }
        return "AO";
    }


    //------------------------------------------COMP MODULE CALCULATION-------------------------------------------------------------------									

    public  void COMP_Calculation (string _data1)
    {

        var file = new System.IO.FileInfo(Server.MapPath("\\Template\\Comp_Output.xlsx"));


        //                        string pathName = System.IO.Path.GetTempPath() + "see" + Guid.NewGuid().ToString();

        Session["SummaryFileName"] = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString() + ".xlsx";


        var sourceFileNew = new System.IO.FileInfo( Session["SummaryFileName"].ToString());

        var summary_file = new System.IO.FileInfo(Server.MapPath("\\Template\\Comp_Output.xlsx"));


        int no_sample = _data1.Split('/').Length;

        double FWL = oilWaterContact;

        using (var xls = new OfficeOpenXml.ExcelPackage(summary_file))
        {
            OfficeOpenXml.ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            var worksheet = xls.Workbook.Worksheets["Template"];
            int i = 1;
            worksheet.Cells[1, 1].Value = "NO";
            worksheet.Cells[1, 2].Value = "Zone";
            worksheet.Cells[1, 3].Value = "Top Depth";
            worksheet.Cells[1, 4].Value = "Bottom  Depth";
            worksheet.Cells[1, 5].Value = "Thickness";
            worksheet.Cells[1, 6].Value = "Kavg";
            worksheet.Cells[1, 7].Value = "Phiavg";
            worksheet.Cells[1, 8].Value = "Pce";
            worksheet.Cells[1, 9].Value = "Swe";
            worksheet.Cells[1, 10].Value = "PcMax";
            worksheet.Cells[1, 11].Value = "Swir";
            for (int j = 1; j < no_sample; j++)
            {
                string data1 = _data1.Split('/')[j];
                MyModel model =  MyModel.GetModel(data1);
                //
                worksheet.Cells[j+1, 1].Value = j;
                worksheet.Cells[j+1, 2].Value = model.Zone;
                worksheet.Cells[j+1, 3]. Value = model.TopDepth;
                worksheet.Cells[j+1,4].Value = model.BottomDepth;
                worksheet.Cells[j+1,5].Value = model.Thickness;
                worksheet.Cells[j+1,6].Value = model.Kavg;
                worksheet.Cells[j+1,7].Value = model.Phiavg;
                worksheet.Cells[j+1,8].Value = model.Pce;
                worksheet.Cells[j+1,9].Value = model.Swe;
                worksheet.Cells[j+1,10].Value = model.PcMax;
                worksheet.Cells[j+1,11].Value = model.Swir;

                double[] ZoneData_Pc = new double[] {model.Pce, model.PcMax} ;
                double[] ZoneData_Sw = new double[] {  model.Swe, model.Swir} ;

                double nStep=(model.BottomDepth-model.TopDepth)/0.1;
                var worksheet1 = xls.Workbook.Worksheets["Sheet1"];
                double rows = nStep + i;
                int counter = 0;
                worksheet1.Cells[1, 1].Value = "Depth";
                worksheet1.Cells[1, 2].Value = "Swi";
                worksheet1.Cells[1, 3].Value = "Pc";
                worksheet1.Cells[1, 4].Value = "hc";
                while (i <= rows)
                {
                    double depth = Math.Round(model.TopDepth + counter * 0.1,1);
                    depths.Add(depth);
                    worksheet1.Cells[i + 1, 1].Value = depth;
                    double[] results = SatHeight(model.TopDepth + counter * 0.1, model.Phiavg, FWL, ZoneData_Pc, ZoneData_Sw, oilDensity, waterDensity, resSystem, labSystem);
                    double calculatedSwi = results[0];
                    double calculatedPc = results[1];
                    double calculatedhc = results[2];
                    calculateSwiList.Add(calculatedSwi);
                    calculatePcList.Add(calculatedPc);
                    calculatehcList.Add(calculatedhc);
                    worksheet1.Cells[i + 1, 2].Value = calculatedSwi;
                    worksheet1.Cells[i + 1, 3].Value = calculatedPc;
                    worksheet1.Cells[i + 1, 4].Value = calculatedhc;
                    i++;
                    counter++;
                }
                plot(worksheet1, "Swi vs Depth",20,400,2);
                plot(worksheet1, "Pc vs Depth", 700, 400, 3 );
                plot(worksheet1, "hc vs Depth", 1400, 400, 4);
            }

            xls.SaveAs(summary_file);
            xls.SaveAs(sourceFileNew);
        }



    }// END OFCOMP MODULE

    private void plot(OfficeOpenXml.ExcelWorksheet worksheet, String title, int xPosition, int yPosition, int yColumnNum)
    {

        if (worksheet.Drawings.Any(d => d.Name.Equals(title)))
        {
            ExcelDrawing existingDrawing = worksheet.Drawings.First(d => d.Name.Equals(title));
            worksheet.Drawings.Remove(existingDrawing);
        }
        ExcelChart chart = worksheet.Drawings.AddChart(title, eChartType.XYScatterLines);
        chart.SetSize(600, 600);
        chart.SetPosition(xPosition, yPosition);
        chart.YAxis.Orientation = eAxisOrientation.MaxMin;
        ExcelChartSerie series2 = chart.Series.Add(worksheet.Cells[2, 1, worksheet.Dimension.End.Row, 1], worksheet.Cells[2, yColumnNum, worksheet.Dimension.End.Row, yColumnNum] );

        // Set chart appearance
        chart.StyleManager.SetChartStyle(ePresetChartStyle.LineChartStyle10);
        chart.Title.Text = title;
    }

    static double[] SatHeight(double Zone_Depth, double Porosity, double FWL, double[] Pc, double[] Sw, double HC_Density, double Water_Density, string Res_Sys, string Lab_Sys)
    {

        //Program Description: 
        //Created Date: 2018 Nov, 20 	
        //Purpose: to calculate Water Saturation (Sw) at a given depth from the generating CP curve bu using MCPK method
        // Input Parameters:
        //		Zone_Depth: Top Depth of a Zone (unit: m).
        //		  Porosity: Porosity of a Zone (unit: fraction).
        //			   FWL: Free Water Level (unit: m)
        //				Pc: A set data of Capillary Pressure from Lab Measurement (unit: psi)
        //				Sw: A set data of Water Saturation from Lab Measurement (unit: fraction)
        //		HC_Density: Oil or Gas Density (unit: psi/ft)
        //	 Water_Density:	Water Density (unit: psi/ft)
        //		   Res_Sys: Type of Reservoir System (OW: Oil-Water; GW:Gas-Water)
        //		   Lab_Sys: Type of Lab System ("OW": Oil-Water; "AW": Air-Water; "AM": Air-Mercury; "AO": Air-Oil)	
        // Output:
        //		SatHeight()[0]: provide a value of water saturation at the entered depth.
        //		SatHeight()[1]: provide a value of capillary pressure at the entered depth.	
        //		SatHeight()[2]: provide a value of capillary height at the entered depth.	

        double res_sig_cos=0;
        double lab_sig_cos=0;

        // Reservoir condition
        const double res_theta_wo = 30;
        const double res_theta_wg = 0;

        const double res_sigma_wo = 30;
        const double res_sigma_wg = 50;

        // Lab condition
        const double lab_theta_aw = 0;
        const double lab_theta_ow = 30;
        const double lab_theta_am = 140;
        const double lab_theta_ao = 0;

        const double lab_sigma_aw = 72;
        const double lab_sigma_ow = 48;
        const double lab_sigma_am = 480;
        const double lab_sigma_ao = 24;

        switch (Res_Sys)
        {
            case "OW":
                res_sig_cos = res_sigma_wo * Math.Cos(res_theta_wo*Math.PI/180);
                break;
            case "GW":
                res_sig_cos = res_sigma_wg * Math.Cos(res_theta_wg*Math.PI/180);
                break;
        }

        switch (Lab_Sys)
        {
            case "AW":
                lab_sig_cos = lab_sigma_aw * Math.Cos(lab_theta_aw*Math.PI/180);
                break;
            case "OW":
                lab_sig_cos = lab_sigma_ow * Math.Cos(lab_theta_ow*Math.PI/180);
                break;
            case "AM":
                lab_sig_cos = lab_sigma_am * Math.Cos(lab_theta_am*Math.PI/180);
                break;
            case "AO":
                lab_sig_cos = lab_sigma_ao * Math.Cos(lab_theta_ao*Math.PI/180);
                break;
        }
        //Convert from depth into cappilary height
        double hc = FWL - Zone_Depth;

        //Convert from cappilary into cappilary pressure
        double Zone_Pc = hc * 3.28*(Water_Density - HC_Density)/(res_sig_cos/lab_sig_cos);

        double Pce = Pc_Prediction(MCKP_Method(Pc, Sw,Porosity)[0],MCKP_Method(Pc, Sw,Porosity )[1],0.999,Porosity);

        double[] result = new double[3];

        if ((Zone_Pc < Pce))
        { result[0] = 0.999;
            result[1] = Pce;
        }
        else
        { result[0] = Sw_Prediction(MCKP_Method(Pc, Sw, Porosity)[0],MCKP_Method(Pc, Sw, Porosity)[1], Zone_Pc,Porosity);
            result[1] = Zone_Pc;
        }
        result[2] = hc;

        return result;
    }

    // Program: To predict Pc from Sw of Lab Data.	
    static double Pc_Prediction(double m, double b, double Sw, double Por)
    {
        double result = 0.0314/((m*((Por*Sw)/(1-Por*Sw))+b)*Math.Sqrt(Por*Sw));
        return result;
    }

    static double ESG( double Sw, double Por)
    {
        double result = (Por*Sw)/(1-Por*Sw);
        return result;
    }

    static double CPI(double Pc, double Sw, double Por)
    {
        double result = 0.0314*Math.Sqrt((1/(Pc*Pc))/(Por*Sw));
        return result;
    }

    // Program: to output slope, intercept and R2 by using MCKP method
    static double[] MCKP_Method(double[] Pc, double[] Sw, double Por )
    {
        double sumX = 0;
        double sumY = 0;
        double sumYYpred =0;
        double sumXXvar = 0;
        double sumYYvar = 0;
        double sumXYvar = 0;
        double[] result = new double[3];

        int count = Pc.Length;
        double[] Y = new double[count];
        double[] X = new double[count];

        for (int i = 0; i < count; i++ )
        {
            X[i] = ESG(Sw[i], Por);
            Y[i] = CPI(Pc[i], Sw[i],Por);
            sumX += X[i];
            sumY += Y[i];
        }

        double avgX = sumX / count;
        double avgY = sumY / count;

        for (int i = 0; i < count; i++ )
        {
            sumXYvar += (X[i]-avgX)*(Y[i]-avgY);
            sumXXvar += (X[i]-avgX)*(X[i]-avgX);
            sumYYvar += (Y[i]-avgY)*(Y[i]-avgY);
        }

        double m =   sumXYvar/sumXXvar;
        double b = avgY-m*avgX;

        for (int i = 0; i < count; i++ )
        {
            sumYYpred += (m*X[i]+b-Y[i])*(m*X[i]+b-Y[i]);
        }

        double R2 = 1- sumYYpred/sumYYvar;

        result[0] = m;
        result[1] = b;
        result[2] = R2;

        return result;
    }

    // Program: used to calculate in Sw_Prediction function.		
    static double Sw_function(double m, double b, double Pc, double Sw, double Por)
    {
        double result = m*Por*Sw/(1-Por*Sw)- 0.0314/(Pc*Math.Sqrt(Por*Sw))+b;
        return result;
    }

    // Program: To predict Sw from Pc.		
    static double Sw_Prediction(double m, double b, double Pc, double Por)
    {
        double xA = 0.1;
        double xB = 1.0;
        double epsilon = 0.001;
        double delta =0;

        double x1 = xA - (xB-xA)*Sw_function(m,b,Pc,xA,Por)/(Sw_function(m,b,Pc,xB,Por)-Sw_function(m,b,Pc,xA,Por));

        while (delta > epsilon)
        {
            if (Sw_function(m,b,Pc,xA,Por)*Sw_function(m,b,Pc,x1,Por)>0)
            {
                xA = x1;
                x1 = xA - (xB-xA)*Sw_function(m,b,Pc,xA,Por)/(Sw_function(m,b,Pc,xB,Por)-Sw_function(m,b,Pc,xA,Por));
                delta = Math.Abs(x1-xA);
            }
            else
            {
                xB = x1;
                x1 = xA - (xB-xA)*Sw_function(m,b,Pc,xA,Por)/(Sw_function(m,b,Pc,xB,Por)-Sw_function(m,b,Pc,xA,Por));
                delta = Math.Abs(x1-xB);
            }
        }

        double result = x1;
        return result;
    }

    // Program: Calculate R2 by using SME and SMT
    public static double R2(List<double> Y_lab, List<double> Y_model)
    {

        double sumYYpred = 0;
        double sumYYvar = 0;
        double R2;
        double sumY = 0;

        int count = Y_lab.Count;

        for (int i = 0; i < count; i++)
        {
            sumY = sumY + Y_lab[i];
        }

        double avgY = sumY / count;


        for (int i = 0; i < count; i++)
        {
            sumYYvar += (Y_lab[i] - avgY) * (Y_lab[i] - avgY);
            sumYYpred += (Y_lab[i] - Y_model[i]) * (Y_lab[i] - Y_model[i]);
        }


        R2 = 1 - sumYYpred / sumYYvar; // Calculate R2 by using a coefficient of determination;	


        return R2;
    }

    //Program: COMP- Best Fit


    protected void Comp_Excel_Export(object sender, DirectEventArgs e)
    {


        var summary_file = new System.IO.FileInfo(Session["SummaryFileName"].ToString());


        //using (var xls = new OfficeOpenXml.ExcelPackage(summary_file))
        //{
        //    xls.Workbook.Worksheets.Delete(2);
        //    xls.Save();

        //}

        Response.Clear();
        Response.AddHeader("Content-Disposition", "attachment; filename=COMP_Summary.xlsx" );
        Response.AddHeader("Content-Length", summary_file.Length.ToString());
        Response.ContentType = "application/vnd.ms-excel";
        Response.Flush();
        Response.WriteFile(summary_file.FullName);
        Response.End();



    }

</script>

<!DOCTYPE html>

<html>
<head runat="server">
    <title>Viewport with BorderLayout - Ext.NET Examples</title>
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>

</head>
<body>
    <ext:ResourceManager runat="server" Theme="Gray" />

    <ext:Viewport runat="server"  Layout="BorderLayout">
        <Items>

            <ext:Panel runat="server"  Region="South" Flex="1" Title="Panel 1" Split="false" Collapsible="true" CollapseDirection="Left" Layout="BorderLayout" Border="false" Header="false" >
               <Items>
 
                            <ext:Panel runat="server" Region="Center"  >
                                <Items>
                               <ext:TabPanel runat="server" ActiveTabIndex="0" TabPosition="Top" Border="false">
                                        <Items>

                                            <ext:Panel runat="server" Title="Result Data" Border="false" Layout="FitLayout"  BodyPadding="6"  >
                                                  <Items>

                                                    <ext:GridPanel ID="Comp_Summary3_GridPanel"  runat="server"  AutoScroll="true" Height="315"  >
                                                                                                            
                                                        <Store>
                                                            <ext:Store runat="server" ID="Comp_Summary3_Store"  >
  
                                                                <Model>
                                                                    <ext:Model runat="server">
                                                                        <Fields>
                                                                            <ext:ModelField Name="depth" />
                                                                            <ext:ModelField Name="calculatedSwi" />
                                                                            <ext:ModelField Name="calculatedPc" />
                                                                            <ext:ModelField Name="calculatedhc" />
                                                                        </Fields>
                                                                    </ext:Model>
                                                                </Model>
                                                            </ext:Store>
                                                        </Store>
                                                        <ColumnModel runat="server">
                                                            <Columns>
                                                                 <ext:Column runat="server" Text="Depth" DataIndex="depth" Width="135px" Align="Center"  />
                                                                 <ext:Column runat="server" Text="Swi" DataIndex="calculatedSwi" Width="135px"  Align="Center" />
                                                                 <ext:Column runat="server" Text="Pc" DataIndex="calculatedPc" Width="135px"  Align="Center" />
                                                                 <ext:Column runat="server" Text="hc" DataIndex="calculatedhc" Width="135px"  Align="Center" />
       

                                                            </Columns>
                                                        </ColumnModel>
                                                             <SelectionModel>
                                                                    <ext:CheckboxSelectionModel  runat="server" Mode="Multi" >
                                                                        <Listeners>

                                                                         </Listeners>

                                                                    </ext:CheckboxSelectionModel>
                                                            </SelectionModel> 

<%--                                                        <BottomBar>
                                                            <ext:PagingToolbar runat="server"/>
                                                        </BottomBar>--%>
                    
                                                        
                                                    </ext:GridPanel>

                                                </Items>
                                        </ext:Panel>

                                        </Items>
                                    </ext:TabPanel>
                               </Items>
 
                            </ext:Panel>
 
               </Items>
             <Buttons>
                       
 <%--               <ext:Button ID="cmdExport_micp" runat="server"  Text="Export" Icon="PageExcel" >
                    <DirectEvents>
                        <Click OnEvent="ExcelExport_click" IsUpload="true"/>
                       
                    </DirectEvents>
                </ext:Button> --%>
 
            </Buttons>

 
            </ext:Panel>

            <ext:Panel  runat="server" Region="Center" Height ="255" Title="Panel 2" Split="true" Collapsible="true" CollapseDirection="Right"   Layout="BorderLayout" Border="false" Header="false" >

                <Items>
                    <ext:Panel ID="comp_Plot2" Title="Plot2" runat="server" Flex="1"  Region="Center" Header="false"  >
                        <Content>
                            <div id="container2" style="   height:390px; min-height:350px; width:600px; min-width:350px; margin-left:auto; margin-right:auto;   " ></div>
                        </Content>
                    </ext:Panel> 
                    <ext:Panel ID="comp_Plot3" Title="Plot3" runat="server" Flex="1"  Region="East" Header="false">
                        <Content>
                            <div id="container3" style="  height:390px; min-height:350px; width:600px; min-width:350px; margin-left:auto; margin-right:auto;  "></div>
                        </Content>
                    </ext:Panel> 


                    <ext:Panel ID="comp_Plot1" Title="Plot1" runat="server" Flex="1"  Region="West" Header="false">
                        <Content>
                            <div id="container1" style="  height:390px; min-height:350px; width:600px; min-width:350px; margin-left:auto; margin-right:auto;  "></div>
                        </Content>
                    </ext:Panel> 

                </Items>
  
            </ext:Panel> 




        </Items>
    </ext:Viewport>




<script>


    var export_click = function ()
    {

        //window.alert("Hello");

        App.direct.Comp_Excel_Export();


    }

    var mycolors = ["#7cb5ec", "#434348", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#2b908f", "#f45b5b", "#91e8e1"];
        var _depths = [];
        var _calculatedSwis = [];
        var _calculatedPcs = [];
        var _calculatedhcs = [];

    var series2 = [];


    var depths = ("<%= depths %>");
    var calculatedSwis = ("<%= calculateSwiList %>");
    var calculatedPcs = ("<%= calculatePcList %>");
    var calculatedhcs = ("<%= calculatehcList %>");

    <% foreach (double item in depths) { %>
    _depths.push(parseFloat('<%=item%>'));
    <% } %>
    <% foreach (double item in calculateSwiList) { %>
    _calculatedSwis.push(parseFloat('<%=item%>'));
    <% } %>

    <% foreach (double item in calculatePcList) { %>
    _calculatedPcs.push(parseFloat('<%=item%>'));
    <% } %>

    <% foreach (double item in calculatehcList) { %>
    _calculatedhcs.push(parseFloat('<%=item%>'));
    <% } %>
      
//        series2.push({
//            name: 'Swi vs depth' ,
//            type: 'line',
//            showInLegend: true,
//            data: [],
//            marker: { enabled: false },
//            color: mycolors[0]
//
//        });
//    for (var i = 0; i < depths.length; i++) {
//        series2.data.push([depths[i], calculatedSwis[i]]);
//        }
//
//
//
//    // Prepare for plotting
//
//
//// First Chart
//    Highcharts.chart('container1', {
//
//        chart: {
//            zoomType: 'xy',
//
//        },
//
//    title: { text: '<b>swi vs depth</b>', useHTML:true},
// legend: {
//     enabled: true,
//
//     layout: 'vertical',
//     align: 'right',
//     verticalAlign: 'middle',
//     //floating:true,
//     //itemMarginRight: 0,
//     //y: 35,
//    },
//
//    xAxis: {
//        labels: {  format: '{value} ' },
//         gridLineWidth: 1.5,
//        title: { text: 'depth' },
//        min:0
//    },
//
//    yAxis: {
//        //type: 'logarithmic',
//        title: { text: 'swi', useHTML:true},
//        //minorTickInterval: 0.1
//    },
//
//
//
//    tooltip: {
//        headerFormat: '<b></b><br />',
//        pointFormat: 'depth = {point.x:.2f}, c<sub>p</sub> = {point.y:.2f}',
//        useHTML:true
//        },
//    navigation: {
//        buttonOptions: {
//            symbolStroke: 'gray',
//            verticalAlign: 'top',
//
//        }
//        },
//
//    series: series2
//
//    }
//
//
//    );

    // Create a chart
    Highcharts.chart('container1', {
        // Define chart options
        chart: {
            type: 'line',
            zoomType: 'xy'
        },
        exporting: {
            enabled: true
        },
        title: {
            text: 'Swi vs depth data'
        },
        // Set the x-axis title
        xAxis: {
            title: {
                text: 'Swi'
            }
        },
        // Define the y-axis
        yAxis: {
            title: {
                text: 'depth'
            },
            reversed: true
        },
        // Define the data series
        // Set the data series
        series: [{
            name: 'Swi vs depth data',
            data: _calculatedSwis.map((x, i) => [x, _depths[i]])
        }]
    });

    // Create a chart
    Highcharts.chart('container2', {
        // Define chart options
        chart: {
            type: 'line',
            zoomType: 'xy'
        },
        exporting: {
            enabled: true
        },
        title: {
            text: 'Pc vs depth data'
        },
        // Set the x-axis title
        xAxis: {
            title: {
                text: 'Pc'
            }
        },
        // Define the y-axis
        yAxis: {
            title: {
                text: 'depth'
            },
            reversed: true
        },
        // Define the data series
        // Set the data series
        series: [{
            name: 'Pc vs depth data',
            data: _calculatedPcs.map((x, i) => [x, _depths[i]])
        }]
    });

    // Create a chart
    Highcharts.chart('container3', {
        // Define chart options
        chart: {
            type: 'line',
            zoomType: 'xy'
        },
        exporting: {
            enabled: true
        },
        title: {
            text: 'hc vs depth data'
        },
        // Set the x-axis title
        xAxis: {
            title: {
                text: 'hc'
            }
        },
        // Define the y-axis
        yAxis: {
            title: {
                text: 'depth'
            },
            reversed: true
        },
        // Define the data series
        // Set the data series
        series: [{
            name: 'hc vs depth data',
            data: _calculatedhcs.map((x, i) => [x, _depths[i]])
        }]
    });


</script>

</body>

</html>