<%@ Page Language="C#" %>
<%@ Register Assembly="Ext.Net" Namespace="Ext.Net" TagPrefix="ext" %>
<%@ Import Namespace="Work.Data" %>
<%@ Import Namespace="OfficeOpenXml" %>
<%-- <%@ Import Namespace="System.DirectoryServices.AccountManagement" %> --%>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Xml.Xsl" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%-- <%@ Import Namespace="ICDMS" %> --%>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>

<!DOCTYPE html>

<html>
<script runat="server">


    public string[] temp_data3 = new string[50];

    public List<MyModel> comp_list_data1= new List<MyModel> ();
    public List<string> comp_list_data2= new List<string>();

    private string[] column_name = new string[] { "Status", "Zone", "TopDepth", "BottomDepth", "Thickness", "Kavg", "Phiavg", "Pce", "Swe", "PcMax", "Swir"};

    private object GetData(List<string> _data)
    {
        var data = new List<object>();

        for (int i = 0; i < _data.Count; i++)
        {
            data.Add(MyModel.GetModel(_data[i]));
        }

        return data;
    }

    private string f_lab_template = @"<table style='border-spacing: 0;width:220px;'>
                                <tr><td style='border: 1px solid rgb(231,231,231);padding: 1 1 1 1;'><i>Field</i></td>
                                    <td style='border: 1px solid rgb(231,231,231);padding: 1 1 1 1;background-color: #90EE90;'><b>{0}</b></td>
                                </tr>
                                <tr>
                                    <td style='border: 1px solid rgb(231,231,231);padding: 1 1 1 1;'><i>Well</i></td>
                                    <td style='border: 1px solid rgb(231,231,231);padding: 1 1 1 1;background-color: #90EE90;'><b>{1}</b></td>
                                </tr>
                                </table>";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!X.IsAjaxRequest)
        {
            this.app_id.Value = Request["id"];
            // if (Session["User_ID"] == null) Response.Redirect("/Home/Logon.aspx?id=1");
            ResourceManager1.RegisterIcon(Icon.Error);
            ResourceManager1.RegisterIcon(Icon.TableCell);
            comp_list_data1.AddRange(MyModel.GetinitialDatas());

            bind_data();

        }


    }


    private void AddField(ModelField field)
    {
        if (X.IsAjaxRequest)
        {
            comp_store.AddField(field);
        }
        else
        {
            comp_store.Model[0].Fields.Add(field);
        }
    }
    /*
     * This function prepares model for input data
     */
    private void bind_data()
    {
        if (X.IsAjaxRequest)
        {
            this.comp_store.RemoveFields();
        }

        // first fix meta data
        for (int i = 0; i < column_name.Length; i++)
        {
            this.AddField(new ModelField() { Name = column_name[i] });
        }
        comp_store.RebuildMeta();
        //        comp_store.DataSource = this.comp_data;
        comp_store.DataSource = comp_list_data1;
        comp_store.DataBind();

    # region Prepare Column Model 

        Column ColumnInfo=new Column(){ ID="ColumnInfo",Text=""};

        Column col1=new Ext.Net.Column() { Width = 80, ID = "Zone", Text = "Zone", DataIndex = "Zone", Sortable = true, Align = ColumnAlign.Center };
        col1.Editor.Add(new TextField() );
        ColumnInfo.Columns.Add(col1);

        Column col2 = new Ext.Net.Column() { Width = 80, ID = "TopDepth", Text = "Top<br> Depth", DataIndex = "TopDepth", Sortable = true, Align = ColumnAlign.Center };
        col2.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col2);

        Column col3 = new Ext.Net.Column() { Width = 80, ID = "BottomDepth", Text = "Bottom<br>Depth", DataIndex = "BottomDepth", Sortable = true, Align = ColumnAlign.Center };
        col3.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col3);

        Column col4 = new Ext.Net.Column() { Width = 150, ID = "Thickness", Text = "Thickness", DataIndex = "Thickness", Sortable = true, Align = ColumnAlign.Center};
        col4.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col4);

        Column col5 = new Ext.Net.Column() { Width = 150, ID = "Kavg", Text = "K avg", DataIndex = "Kavg", Sortable = true, Align = ColumnAlign.Center };
        col5.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col5);

        Column col6 = new Ext.Net.Column() { Width = 150, ID = "Phiavg", Text = "phi avg", DataIndex = "Phiavg", Sortable = true, Align = ColumnAlign.Center };
        col6.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col6);

        Column col7 = new Ext.Net.Column() { Width = 150, ID = "Pce", Text = "Pce", DataIndex = "Pce", Sortable = true, Align = ColumnAlign.Center };
        col7.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col7);

        Column col8 = new Ext.Net.Column() { Width = 80, ID = "Swe", Text = "Swe", DataIndex = "Swe", Sortable = true, Align = ColumnAlign.Center };
        col8.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col8);

        Column col19 = new Ext.Net.Column() { Width = 80, ID = "PcMax", Text = "Pc max", DataIndex = "PcMax", Sortable = true, Align = ColumnAlign.Center };
        col19.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col19);

        Column col10 = new Ext.Net.Column() { Width = 150, ID = "Swir", Text = "Swir ", DataIndex = "Swir", Sortable = true, Align = ColumnAlign.Center };
        col10.Editor.Add(new TextField());
        ColumnInfo.Columns.Add(col10);

        comp_gridpanel.ColumnModel.Columns.Add(ColumnInfo);

#endregion Prepare Column Model

        // column data
        // column delete control
        CommandColumn command2 = new CommandColumn() { Width = 60, OverOnly = true, Border = false };
        GridCommand gridcommand2 = new GridCommand(){ CommandName="InputData", Text="Edit",  Icon=Icon.TableEdit};
        gridcommand2.ToolTip.Title="Edit Input Data";

        command2.Commands.Add(gridcommand2);
        command2.Listeners.Command.Handler = "displayDataset(record)";
        comp_gridpanel.ColumnModel.Columns.Add(command2);

        // column delete control
        CommandColumn command = new CommandColumn() { Width = 25, OverOnly = true, Border = false };
        GridCommand gridcommand=new GridCommand(){ CommandName="delete", Icon=Icon.Decline};
        gridcommand.ToolTip.Title="Delete this plug";
        command.Commands.Add(gridcommand);
        command.Listeners.Command.Handler = "delete_plug(record)";
        comp_gridpanel.ColumnModel.Columns.Add(command);
    }


    /*
     * Get ip address of user
     * */

    protected string get_ip_address()
    {

        string visitor_ip_addr = string.Empty;
        if (HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] != null)
        {
            visitor_ip_addr = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"].ToString();
        }
        else if (HttpContext.Current.Request.UserHostAddress.Length != 0)
        {
            visitor_ip_addr = HttpContext.Current.Request.UserHostAddress;
        }
        return visitor_ip_addr;
    }

    // Store refresh
    protected void comp_store_refresh(object sender, EventArgs e)
    {
        this.bind_data();
    }

    
    protected void comp_upload_click(object sender, DirectEventArgs e)
    {
        if (this.FileUploadField2.HasFile)
        {
            HttpPostedFile file_upload = this.FileUploadField2.PostedFile;

            string pathName = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString();
            file_upload.SaveAs(pathName);

            var file = new System.IO.FileInfo(pathName);
            comp_list_data1 = MyModel.GetModelsFromExcelFile(pathName);
            this.bind_data();
            this.upload_window.Hide();
            List<String> comp_list_data1_str =  comp_list_data1.Select(item => item.ToString()).ToList();
            string comp_list_data1_json = new JavaScriptSerializer().Serialize(comp_list_data1_str);
            X.AddScript("addDataset(" + comp_list_data1_json + ");");
        }

    }

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

    protected void my_message(object sender, EventArgs e)
    {

        X.Msg.Show(new MessageBoxConfig
        {
            Buttons = MessageBox.Button.OK,
            Icon = MessageBox.Icon.INFO,
            Title = "Information!",
            Message = "This feature is under implementation. It will be updated soon."

        });

    }

</script>
<head id="Head1" runat="server">
    
    <title></title>
    <link href="/resources/css/Apps.css" rel="stylesheet" />       
    <style type="text/css">
        .dirty-row .x-grid-cell, .dirty-row .x-grid-rowwrap-div {
	        background-color:    #FFCC66 !important;
	        font-style:italic;
        }
        .x-grid-row-over .x-grid-cell-inner {
            font-weight : bold;
        }
        .new-row .x-grid-cell, .new-row .x-grid-rowwrap-div {
	        background: #c8ffc8 !important;
        } 
        .css1 .x-panel-body
        {
            background-color:  white !important;
        }
        .msgClsCustomLoadMask{
                border: hidden;
                
        }
        
        .summary-class .x-grid-cell, .summary-class .x-grid-rowwrap-div,.summary-class {
	        background:  #e8e8e8 !important;
        } 
        
        .homo-class .x-grid-cell, .homo-class .x-grid-rowwrap-div,.homo-class{
	        background: #ccffcc !important;
        } 
        .homo-pore-fill-class .x-grid-cell, .homo-pore-fill-class .x-grid-rowwrap-div,.homo-pore-fill-class{
	        background: #9dd89c !important;
        } 
        
        
        .bi-class .x-grid-cell, .bi-class .x-grid-rowwrap-div,.bi-class  {
	        background: #ffffb3 !important;
        } 
        
        
        .bi-pore-fill-class .x-grid-cell, .bi-pore-fill-class .x-grid-rowwrap-div,.bi-pore-fill-class  {
	        background: #ffe791 !important;
        } 
        
        
        .broad-class .x-grid-cell, .broad-class .x-grid-rowwrap-div,.broad-class {
	        background: #b75150 !important;
        } 
        
        .broad-bimodal-class .x-grid-cell, .broad-bimodal-class .x-grid-rowwrap-div,.broad-bimodal-class {
	        background: #f9afae !important;
        } 
                  
        .x-tab-active{
           border-color: #0000ff #0000ff #0000ff #0000ff;
        }

        
    </style>
    
 
<script>


    var comp_data1 = [                 
                    "1,1-10,3208.2,3210.2,2.07,52.99,0.167,0.587,0.999,60,0.226",
                    "2,11-21,3210.2,3213.2,2.94,112.99,0.190,0.382,0.999,60,0.202",
                    "3,22-36,3213.2,3215.9,2.74,100.64,0.175,0.409,0.999,60,0.203",
                    "4,37-45,3215.9,3218.9,3.01,160.51,0.149,0.308,0.999,60,0.181",
                    "5,46-68,3218.9,3225.7,6.83,546.87,0.156,0.133,0.999,60,0.145",
                    "6,69-80,3225.7,3229.9,4.16,503.87,0.171,0.142,0.999,60,0.150",
                    "7,81-87,3229.9,3232.3,2.43,369.64,0.162,0.177,0.999,60,0.157",
                    "8,88-109,3232.3,3237.8,5.77,7.62,0.131,1.417,0.999,60,0.310",
                    "9,110-120,3237.8,3241.1,3.3,0.13,0.098,3.199,0.999,60,0.619",
                    "10,121-132,3241.1,3244,2.85,0.10,0.110,3.217,0.999,60,0.675",
                    "11,133-156,3244,3250.9,6.95,42.31,0.120,0.661,0.999,60,0.222",
                    "12,157-171,3250.9,3254.5,3.6,439.87,0.123,0.156,0.999,60,0.145",
                    "13,172-181,3254.5,3256.5,1.95,361.54,0.178,0.179,0.999,60,0.161",
                    "14,182-186,3256.5,3259,2.5,2.74,0.159,1.984,0.999,60,0.388",
                    "15,187-211,3259,3265.4,6.46,229.74,0.101,0.244,0.999,60,0.157",
                    "16,212-225,3265.4,3271.2,5.74,67.84,0.144,0.513,0.999,60,0.211",
                    "17,226-237,3271.2,3273.2,2.05,46.81,0.175,0.627,0.999,60,0.234",
                    "19,242-260,3274.7,3279.8,5.09,2.35,0.139,2.070,0.999,60,0.390",
                    "20,261-279,3279.8,3284.6,4.81,19.83,0.185,0.955,0.999,60,0.277",
                    "21,280-330,3284.6,3300.8,16.2,907.15,0.124,0.091,0.999,60,0.127",
                    "22,331-350,3300.8,3306.4,5.63,0.07,0.062,3.208,0.999,60,0.640",
                    "23,351-360,3306.4,3309.8,3.37,0.11,0.079,3.215,0.999,60,0.624",
                    "24,361-368,3309.8,3312.8,2.95,36.75,0.146,0.710,0.999,60,0.237",
                    "25,369-375,3312.8,3314.9,2.15,0.20,0.070,3.139,0.999,60,0.541",
                    "26,376-378,3314.9,3315.7,0.76,25.71,0.099,0.846,0.999,60,0.235",
                    "27,379-387,3315.7,3318.6,2.98,274.32,0.161,0.217,0.999,60,0.166",
                    "28,388-398,3318.6,3354.6,39.46,432.77,0.148,0.158,0.999,60,0.150",
                    "29,399-420,3354.6,3361.5,6.89,125.67,0.133,0.358,0.999,60,0.185",
                    "30,421-432,3361.5,3364.8,3.32,134.32,0.136,0.344,0.999,60,0.183",
    ];


//----------------------------Add Tabpanel---------------------------
            var addTab = function(tabPanel) {
                //Summary

                var temp1 = "";
                var resSystem = App.cmbResSystem.getValue().toString();
                var labSystem = App.TextLabSystem.getValue().toString();
                var oilWaterContact = App.TextOilWaterContact.getValue().toString();
                var oilDensity = App.TextOilDensity.getValue().toString();
                var waterDensity = App.TextWaterDensity.getValue().toString();

                for (var i = 0; i < comp_data1.length; i++) {
                    temp1 = temp1 + '/' + comp_data1[i];
                }

                temp1 = temp1.substr(1, temp1.length);

                var url2 = "./Summary.aspx?comp_data1=" + temp1 + "&resSystem=" + resSystem + "&labSystem=" + labSystem + "&oilWaterContact=" + oilWaterContact + "&oilDensity=" + oilDensity + "&waterDensity=" + waterDensity;
                tab = tabPanel.add({
                    id: "comp_summary",
                    title: "Summary",
                    closable: true,
                    loader: {
                        url: url2,
                        renderer: "frame",
                        loadMask: {
                            showMask: true,
                            msg: "Loading Summary ..."
                        }
                    }
                });
                tabPanel.setActiveTab("comp_summary");
            }


            var addDataset = function (records) {
        console.log(records);
        var grid = App.comp_gridpanel;
        var store = grid.getStore();


               
        var _Order = grid.getStore().getCount();

        comp_data1 = [];


        store.removeAll();
        
 
        for (var i = 0; i < records.length; i++)
        {
            comp_data1.push(records[i].toString());

  
        var data1 = comp_data1[i].toString().split(',');
//        "Status", "Zone", "TopDepth", "BottomDepth", "Thickness", "Kavg", "Phiavg", "Pce", "Swe", "PcMax", "Swir"
            
            store.insert(i, {
                Zone: data1[1], TopDepth: data1[2], BottomDepth: data1[3], Thickness: data1[4],
                Kavg: data1[5], Phiavg: data1[6], Pce: data1[7], Swe: data1[8], PcMax: data1[9],
                Swir: data1[10]
            });


        }
//--------------------------------
                 
//                  App.upload_window.hide();

    };

            var displayDataset = function (record)

            {

                var grid = App.comp_gridpanel;
                var store = grid.getStore();

                App.insert_window.show();

                App.insert_window.setTitle('Edit - Input Data: ' + record.get('Zone'));
                App.txtZone.setValue(record.get('Zone'));
                App.txtTopDepth.setValue(record.get('TopDepth'));
                App.txtBottomDepth.setValue(record.get('BottomDepth'));
                App.txtThickness.setValue(record.get('Thickness'));
                App.txtKavg.setValue(record.get('Kavg'));
                App.txtPhiavg.setValue(record.get('Phiavg'));
                App.txtPce.setValue(record.get('Pce'));
                App.txtSwe.setValue(record.get('Swe'));
                App.txtPcMax.setValue(record.get('PcMax'));
                App.txtSwir.setValue(record.get('Swir'));

            };

           var updateDataset = function (_pos)
            {

                var grid = App.comp_gridpanel;
               var store = grid.getStore();
               console.log(store.getAt(_pos));
               store.getAt(_pos).set('Zone', App.txtZone.getValue());
               store.getAt(_pos).set('TopDepth', App.txtTopDepth.getValue());
               store.getAt(_pos).set('BottomDepth', App.txtBottomDepth.getValue());
               store.getAt(_pos).set('Thickness', App.txtThickness.getValue());
               store.getAt(_pos).set('Kavg', App.txtKavg.getValue().toString());
               store.getAt(_pos).set('Phiavg', App.txtPhiavg.getValue().toString());
               store.getAt(_pos).set('Pce', App.txtPce.getValue().toString());
               store.getAt(_pos).set('Swe', App.txtSwe.getValue().toString());
               store.getAt(_pos).set('PcMax', App.txtPcMax.getValue().toString());
               store.getAt(_pos).set('Swir', App.txtSwir.getValue().toString())

//---------------comp data1
                var temp = comp_data1[_pos].toString().split(',');
   
               temp[3] = App.txtTopDepth.getValue().toString();   
               temp[4] = App.txtBottomDepth.getValue().toString(); 
               temp[5] = App.txtThickness.getValue().toString(); 
               temp[6] = App.txtKavg.getValue().toString(); 
               temp[7] = App.txtPhiavg.getValue().toString(); 
               temp[8] = App.txtPce.getValue().toString(); 
               temp[9] = App.txtSwe.getValue().toString(); 
               temp[10] = App.txtPcMax.getValue().toString(); 
               temp[11] = App.txtSwir.getValue().toString();

               comp_data1[_pos] = temp.join(',');

               App.insert_window.hide();
                 

            };
    //--------------Click on Apply button
            var cmdApply_comp_click = function ()
            {
                    for (i = 0; i < comp_data1.length;i++)
                    {
                        if (App.txtZone.getValue() == comp_data1[i].toString().split(',')[1])
                        {
                            var _pos = i;
                        }
                    };

            Ext.MessageBox.confirm('Save Changes ', 'Would you like to save your changes ?', function (btn) {
                                                                                if (btn == 'yes') {
                                                                     updateDataset(_pos);
                                                                                                         }
    
            })

                  
            };


    var insert_plug = function ()
    {
                var grid = App.comp_gridpanel;
                var store = grid.getStore();

                    App.insert_window.show();

                App.insert_window.setTitle('Insert Plug Data: ');

                App.txtZone.setValue("");
                App.txtTopDepth.setValue("");
                App.txtThickness.setValue("");
                App.txtKavg.setValue("");
                App.txtPhiavg.setValue("");
                App.txtPce.setValue("");
                App.txtSwe.setValue("");
                App.txtPcMax.setValue("");
                App.txtSwir.setValue("");

    }

    function openPDF() {
        var pdfWindow = window.open();
        pdfWindow.document.write("<embed width='100%' height='100%' src='/resources/Manual.pdf' type='application/pdf'>");
    }

       // when user click delele plug
    var delete_plug = function (record) {
        console.log(record.data.Zone);
        Ext.MessageBox.confirm('Delete Zone ' + record.data.Zone, 'Data will not be recovered, are you sure ?', function (btn) {
                                                                                if (btn == 'yes') {

                    for (var i = 0; i < comp_data1.length; i++) {
                        console.log("test" + comp_data1[i].toString().split(",")[1]);
                        if (comp_data1[i].toString().split(",")[1] == record.get('Zone')) { break; }
                        }
                                                                                    App.comp_store.remove(record);
                                                                                    comp_data1.splice(i, 1);
                                                                                    comp_data2.splice(i, 1);                                                                                                                                                                     
                }


            })
        };

        function reset() {
            Ext.MessageBox.confirm('Confirm', 'Are you sure to reset the current analysis?', function (choice) {
                if (choice == 'yes') {
                    parent.Ext.getCmp(app_id.value).reload();
                }
            });
        }


    var MyMessage = function ()
    {

                                    Ext.Msg.show({
                                 title:'Information',
                                 msg: 'This feature is under implementation. Thank you',
                                 buttons: Ext.Msg.OK,
                                 icon: Ext.Msg.INFO
                            });

    }

</script>


</head>
<body>
    <form id="Form2" runat="server">
        <ext:ResourceManager ID="ResourceManager1" runat="server" />
        
        <ext:Viewport ID="comp_viewport" runat="server" Layout="BorderLayout" >
        <Items>

             <ext:Panel ID="myPanel2" runat="server" Border="false"  Region="North">
                <DockedItems>
                                                <ext:Toolbar ID="Toolbar1" runat="server" Dock="Top" Layout ="HBoxLayout" >
                                                    <Items>

                                                        <%-- <ext:Component ID="Component22" runat="server" Width="2" />    --%>
<%--                                                        <ext:Container ID="Container25" runat="server">
                                                            <Content>
                                                                <img  src='/resources/images/COMP.png' width="82" height="49"/>
                                                                
                                                                <div align='center'>
                                                                    <font color='#0066ff'>Version 3.1</font>
                                                                </div>
                                                            </Content>
                                                        </ext:Container>--%>

                                                      <%--  <ext:BoxSplitter runat="server" Width="10"/>--%>

                                                        <ext:ButtonGroup runat="server" Title="<b>Document</b>"  HeaderPosition="Bottom">
                                                            <Items>
                                                                <ext:Button ID="Button3" runat="server"  Text="Guide" IconUrl="/resources/images/guide.png"  Scale="Large"  Width="80" Handler="openPDF()"   IconAlign="Top" Disabled="false" />
                                                            </Items>
                                                        </ext:ButtonGroup>

                                                        <ext:ToolbarSeparator runat="server" />

                                                        <ext:ButtonGroup runat="server" Title="<b>Dataset</b>"  HeaderPosition="Bottom">
                                                            <Items>
                                                               <ext:Button ID="cmdImport" runat="server" Cls="text-muted"  Text="Import" IconUrl="/resources/images/import.png" Scale="Large"  Width="80" IconAlign="Top" Disabled="false">
                                                                    <Listeners>
                                                                         <Click Handler="App.upload_window.show();" />                                         
                                                                    </Listeners>

                                                               </ext:Button>
                                                         <ext:Button ID="Button8" runat="server" Text="Edit" IconUrl="/resources/images/edit.png" Scale="Large"  Width="80" Handler="" IconAlign="Top" MenuArrow="false" ToolTip=" a new plug in the current dataset." ToolTipType="Title" >
                                                            <Menu>
									                            <ext:Menu ID="menu1" runat="server" >
										                            <Items>                                                                        
                                                                         <ext:Button ID="cmdInsert" runat="server"  Text="Insert" IconUrl="/resources/images/insert.png" Scale="Large"  Width="80" Handler="insert_plug()" IconAlign="Top"  Disabled="True" />
                                                                         <ext:Button ID="Button13" runat="server"  Text="Remove" IconUrl="/resources/images/delete.png" Scale="Large"  Width="80" OnDirectClick="my_message" IconAlign="Top" Disabled="true" />
										                            </Items>
                                                                </ext:Menu>
                                                            </Menu>
                                                         </ext:Button>

                                                                <ext:Button ID="cmdQc" runat="server"  Text="Quality Check" IconUrl="/resources/images/qc.png" Scale="Large"  Width="80" Handler="MyMessage()" IconAlign="Top"  Disabled="True" />                                                                                                                                 

                                                            </Items>
                                                        </ext:ButtonGroup>

                                                        <ext:ToolbarSeparator runat="server" />

                                                        <ext:ButtonGroup runat="server" Title="<b>Analysis</b>"  HeaderPosition="Bottom">
                                                            <Items>
                                                                <ext:Button ID="cmd" runat="server"  Text="Settings" IconUrl="/resources/images/settings.png" Scale="Large"  Width="80" Handler="App.setting_window.show();" IconAlign="Top"  />                                                                                                                        
                                                                <ext:Button ID="cmdAuto" runat="server"  Text="Auto"  IconUrl="/resources/images/auto.png" Scale="Large"  Width="80" IconAlign="Top">

                                                                    <Listeners>

                                                                        <Click Handler="addTab(#{comp_tabpanel}, this);" />
                                                                         
                                                                    </Listeners>
                                                                </ext:Button>

                                                                <ext:Button ID="Button4" runat="server"  Text="Manual" IconUrl="/resources/images/manual.png" Scale="Large"  Width="80" Handler="MyMessage()" IconAlign="Top"  Disabled="True" />
                                                                <ext:Button ID="Button17" runat="server"  Text="Prediction" IconUrl="/resources/images/prediction.png" Scale="Large"  Width="80" OnDirectClick="my_message" IconAlign="Top" Disabled="true" />
                                                                <ext:Button ID="cmdReset" runat="server"  Text="Reset" IconUrl="/resources/images/reset.png" Scale="Large"  Width="80" Handler="reset();" IconAlign="Top"  Disabled="false" />

                                                            </Items>
                                                        </ext:ButtonGroup>

                                                        <ext:ToolbarSeparator runat="server" />

                                                        <ext:ButtonGroup runat="server" Title="<b>Results</b>"  HeaderPosition="Bottom">
                                                            <Items>
                                                                <ext:Button ID="cmdExport" runat="server"  Text="Export" IconUrl="/resources/images/export.png" Scale="Large"  Width="80" IconAlign="Top" Disabled="false">

                                                                    <DirectEvents>
                                                                        <Click OnEvent="Comp_Excel_Export" IsUpload="true"/>
                       
                                                                    </DirectEvents>
                                                                </ext:Button>

                                                            </Items>
                                                        </ext:ButtonGroup>

                                                         <%-- <ext:Container ID="Container15" runat="server"  Layout="HBoxLayout" Flex="2" >                                                  --%>
                                                         <%--     <Items> --%>
                                                         <%-- --%>
                                                         <%--         <ext:Container ID="Container19" runat="server" Flex="2" /> --%>
                                                         <%--         <ext:Container ID="Container20" runat="server" Layout="VBoxLayout" > --%>
                                                         <%--             $1$ <Items> #1# --%>
                                                         <%--             $1$     <ext:Image runat="server" ImageUrl='/resources/images/COMP.png' Height="65" Margins="0 0 0 0"  /> #1# --%>
                                                         <%--             $1$     <ext:Label runat="server" Text="v3.1 Last build: 03/03/2021" Margins="0 0 0 0" /> #1# --%>
                                                         <%--             $1$ </Items> #1# --%>
                                                         <%--         </ext:Container> --%>
                                                         <%--         <ext:Container ID="Container21" runat="server" Flex="1" />                                 --%>
                                                         <%--     </Items> --%>
                                                         <%-- </ext:Container> --%>

                                                            <%-- <ext:Container ID="Container22" runat="server" Flex="1" >                                          --%>
                                                            <%--     <Items> --%>
                                                            <%-- --%>
                                                            <%--         <ext:Image runat="server" ImageUrl='/resources/images/BnB_logo.png'  Width="259" Height="50" /> --%>
                                                            <%--     </Items> --%>
                                                            <%-- </ext:Container>     --%>
                                                        
                                                    </Items>
                                                </ext:Toolbar>
                                         </DockedItems>
            </ext:Panel>

             <ext:Panel ID="Panel22" runat="server" Border="false"   Layout="FitLayout" Region="Center">
            <Items>

            <ext:TabPanel ID="comp_tabpanel" runat="server"  Border="false" >
             <Plugins>
                <ext:TabScrollerMenu runat="server"
                     MenuPrefixText="Goto"
                />
                <ext:BoxReorderer ID="BoxReorderer1" runat="server" />
                <ext:TabCloseMenu ID="TabCloseMenu1" runat="server"
                    CloseTabText="Close Tab"
                    CloseOtherTabsText="Close Other Tabs"
                    CloseAllTabsText="Close All Tabs" 
                />
            </Plugins>
            <Items>


                <ext:Panel ID="Panel1" runat="server"   Closable="false" Title="Data entry"  Icon="Table"   Layout="BorderLayout" AutoScroll="true" >
                    
                    <Items>

                        <ext:GridPanel ID="comp_gridpanel" runat="server" AutoScroll="true"  Layout="FitLayout" Region="Center" Frame="false" Border="false">
                                            <Store>
                                                <ext:Store ID="comp_store" runat="server" OnReadData="comp_store_refresh"  PageSize="50" ShowWarningOnFailure="true">
                                                    <Model>
                                                        <ext:Model runat="server" ID="COMP_Model" Name="COMP_Model" />
                                                    </Model>
                                                    <Sorters>
                                                        <ext:DataSorter Property="Plug_No" Direction="ASC" />
                                                    </Sorters> 
                                            
                                                    <Listeners>
                                                        <Exception Handler="Ext.Msg.alert('Operation failed', operation.getError());" />                
                                                        <Write Handler="Ext.net.Notification.show({hideDelay: 5000,iconCls  : 'icon-exclamation',html: 'The data successfully saved',title : 'Information'});" />
                                                    </Listeners>
                                                </ext:Store>
                                        

                                            </Store>
                       

                                            <BottomBar>
                                                <ext:PagingToolbar ID="PagingToolbar1" runat="server" StoreID="comp_store" DisplayInfo="false"> 
                                                 
                                                    <Items>
                                                                <ext:Label ID="Label1" runat="server" Text="Page size:" />
                                                                <ext:ToolbarSpacer ID="ToolbarSpacer1" runat="server" Width="10" />
                                                    </Items>
                                                </ext:PagingToolbar>
                                            </BottomBar>
                                  

                                            <SelectionModel>
                                                    <ext:CheckboxSelectionModel ID="CheckboxSelectionModel1" runat="server" Mode="Multi" >
                                                    </ext:CheckboxSelectionModel>
                                            </SelectionModel>

                                            
                                    </ext:GridPanel> 
                    </Items>
                </ext:Panel>
            </Items>
            <Listeners>
                <BeforeRemove Handler="remove_session(arguments[1].id);" />

            </Listeners>
        </ext:TabPanel>

               </Items>
        </ext:Panel>
        </Items>
        </ext:Viewport>

        <!--Window for configuration -->
        <ext:Window ID="insert_window" runat="server" Hidden="true" Modal="true" Title="Insert New Sample Data" Width="400"  Height="570" Layout="BorderLayout"  BodyPadding="5" > 
             <Items>
                     
           <ext:Panel runat="server" Region="West" Width="400"  >
               <Items>
                        
                        <ext:Component ID="Component2" runat="server" Width="10" />

                        <ext:FieldSet ID="FieldSet3" Title="<b> Sample Information</b>" runat="server"  Height="570"  DefaultAnchor="100%">   
                                        <Defaults>
                                            <ext:Parameter Name="LabelWidth" Value="175" />
                                            <ext:Parameter Name="FieldStyle" Value="text-align: center" />
                                   
                                        </Defaults>                        
                            <Items>
                                <ext:TextField ID="txtZone" runat="server" FieldLabel="Zone"  FieldStyle="text-align: center; background:#90EE90" />    
                                            <ext:TextField ID="txtTopDepth" runat="server" FieldLabel="TopDepth"   HideTrigger="true" />                                
                                            <ext:TextField ID="txtBottomDepth" runat="server" FieldLabel="BottomDepth" HideTrigger="true" />
                                            <ext:TextField ID="txtThickness" runat="server" FieldLabel="Thickness"  HideTrigger="true"/>
                                            <ext:NumberField ID="txtKavg" runat="server" FieldLabel="Kavg" HideTrigger="true" />
                                            <ext:NumberField ID="txtPhiavg" runat="server" FieldLabel="Phiavg"  HideTrigger="true" />
                                            <ext:NumberField ID="txtPce" runat="server" FieldLabel="Pce"  HideTrigger="true" />
                                            <ext:NumberField ID="txtSwe" runat="server" FieldLabel="Swe"  HideTrigger="true" />
                                            <ext:NumberField ID="txtPcMax" runat="server" FieldLabel="PcMax"  HideTrigger="true" />
                                            <ext:NumberField ID="txtSwir" runat="server" FieldLabel="Swir"  HideTrigger="true" />
                            </Items>
                        </ext:FieldSet>
                    </Items>
                </ext:Panel>
             </Items> 
                 
            <Buttons>
 
                        <ext:Button ID="cmdCancel_micp" runat="server"  Text="Cancel" Icon="Decline" >
                                        <Listeners>
                                             <Click Handler="App.insert_window.hide();" />                                         
                                        </Listeners>
                        </ext:Button> 
                       <ext:Button ID="cmdApply_micp" runat="server" Text="Apply" Icon="Accept">
                                         <Listeners>
                                              <Click Handler="cmdApply_comp_click();" />                                                                         
                                         </Listeners>
                
                        </ext:Button>
            </Buttons>
    
        </ext:Window>
<!---Window for Setting-------->


        <ext:Window ID="setting_window" runat="server" Title="Setting" Hidden="true" Modal="true" Width="400"  Height="450" Layout="VBoxLayout"  BodyPadding="5" > 
             <Items>
                     
                        <ext:FieldSet ID="FieldSet1" runat="server"  Title="<b>Reservoir Data</b>" Height="270" >
                                        <Defaults>
                                            <ext:Parameter Name="LabelWidth" Value="155" />
                                            <ext:Parameter Name="FieldStyle" Value="text-align: center"  />
                                        </Defaults>                                
                            <Items>
                                            <ext:ComboBox runat="server" ID="cmbResSystem" FieldLabel="Reservoir System">
                                                <Items>
                                                    <ext:ListItem Text="Water/Oil" Value="Water/Oil" />
                                                    <ext:ListItem Text="Gas/Water" Value="Gas/Water" />
                                                </Items>
                                                <SelectedItem Value="Water/Oil" />
                                            </ext:ComboBox>
                                            <ext:ComboBox runat="server" ID="cmbLabSystem" FieldLabel="Lab System">
                                                <Items>
                                                    <ext:ListItem Text="Oil/Water" Value="Oil/Water" />
                                                    <ext:ListItem Text="Air/Water" Value="Air/Water" />
                                                    <ext:ListItem Text="Air/Mercury" Value="Air/Mercury" />
                                                    <ext:ListItem Text="Air/Oil" Value="Air/Oil" />
                                                </Items>
                                                <SelectedItem Value="Oil/Water" />
                                            </ext:ComboBox>
                                            <ext:TextField ID="TextLabSystem" runat="server" FieldLabel="Lab System" Text="Oil/Water" HideTrigger="true" />
                                            <ext:TextField ID="TextOilWaterContact" runat="server" FieldLabel="Oil Water Contact m" Text="3312"   HideTrigger="true" />
                                            <ext:TextField ID="TextOilDensity" runat="server" FieldLabel="Oil Density psi/ft" Text="0.338"  HideTrigger="true" />
                                            <ext:TextField ID="TextWaterDensity" runat="server" FieldLabel="Water Density psi/ft" Text="0.421"  HideTrigger="true" />

                             </Items>

                        </ext:FieldSet>

             </Items> 
                 
            <Buttons>
 
                        <ext:Button ID="Button1" runat="server"  Text="Cancel" Handler="App.setting_window.hide();"  Icon="Decline" >
                                        <Listeners>
                                             <Click Handler="App.setting_window.hide();" />                                         
                                        </Listeners>
                        </ext:Button> 
                       <ext:Button ID="Button2" runat="server" Text="Apply" Icon="Accept">
                                         <Listeners>
                                              <Click Handler="App.setting_window.hide();" />                                                                         
                                         </Listeners>
                
                        </ext:Button>
            </Buttons>
    
        </ext:Window>


      <!--Window for upload -->
         <ext:Window  ID="upload_window" runat="server" Hidden="true" Modal="true" Width="500" Frame="true" Height="200" Title="Import"  BodyStyle="padding:10px;" >                
            
            <Items>
                <ext:FileUploadField  ID="FileUploadField2" Width="450" runat="server"  EmptyText="Select a sample data" FieldLabel="File" ButtonText="" Icon="Attach" Disabled="false" />
                <ext:Label runat="server" ID="import_note" Html=" <div><br><b>Note:</b> A new dataset should be an Excel file with correct format. Refer to <a href='/template/temp.xlsx'>this template</a>.</div>"  />
                <ext:Hidden ID="selected_opt" runat="server" Text="1" />


            </Items>

            <Buttons>
		<ext:Button ID="cmdGuide" runat="server" Icon="BookOpen" Text="Guide"  />
                <ext:Button ID="cmdOk_Load_comp" runat="server" Text="OK" Icon="Accept" >
                                        <DirectEvents>
                                            <Click OnEvent="comp_upload_click" IsUpload="true"/>
                                        </DirectEvents>
                </ext:Button>
                <ext:Button ID="cmdCancel_Load_comp" runat="server" Text="Cancel" Icon="Decline" >
                                        <Listeners>
                                             <Click Handler="App.upload_window.hide();" />                                         
                                        </Listeners>
                </ext:Button>
            </Buttons>
        </ext:Window>        
        
            <ext:Hidden ID="f_field" runat="server" Text="Middle East" />
            <ext:Hidden ID="f_well" runat="server" Text="B1X" />
            <ext:Hidden ID="app_id" runat="server" />  

    </form>
</body>
</html>

