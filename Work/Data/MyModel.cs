using System;
using System.Collections.Generic;
using OfficeOpenXml;

namespace Work.Data
{
    public class MyModel
    {
        public string Zone { get; set; }
        public double TopDepth { get; set; }
        public double BottomDepth { get; set; }
        public double Thickness { get; set; }
        public double Kavg { get; set; }
        public double Phiavg { get; set; }
        public double Pce { get; set; }
        public double Swe { get; set; }
        public double PcMax { get; set; }
        public double Swir { get; set; }

        public MyModel(string zone, double topDepth, double bottomDepth, double thickness, double kavg, double phiavg, double pce, double swe, double pcMax, double swir)
        {
            Zone = zone;
            TopDepth = topDepth;
            BottomDepth = bottomDepth;
            Thickness = thickness;
            Kavg = kavg;
            Phiavg = phiavg;
            Pce = pce;
            Swe = swe;
            PcMax = pcMax;
            Swir = swir;
        }

        public static MyModel GetModel(String excelRow)
        {
            string[] elements = excelRow.Split(',');
            return new MyModel(elements[1], Double.Parse(elements[2]), Double.Parse(elements[3]),
                Double.Parse(elements[4]), Double.Parse(elements[5]), Double.Parse(elements[6]),
                Double.Parse(elements[7]), Double.Parse(elements[8]), Double.Parse(elements[9]),
                Double.Parse(elements[10]));
        }

        public override string ToString()
        {
            return $",{Zone},{TopDepth},{BottomDepth},{Thickness},{Kavg},{Phiavg},{Pce},{Swe},{PcMax},{Swir}";
        }

        public static List<MyModel> GetModelsFromExcelFile(String filePath)
        {
            OfficeOpenXml.ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            var file = new System.IO.FileInfo(filePath);
            using (var package = new OfficeOpenXml.ExcelPackage(file))
            {
                var worksheet = package.Workbook.Worksheets["Sheet1"];
                int columnCount = worksheet.Dimension.End.Column;
                int rowCount = worksheet.Dimension.End.Row;

                string[] rowData = new string[columnCount];
                List<MyModel> results = new List<MyModel> ();

                for (int rowNumber = 2; rowNumber <= rowCount; rowNumber++)
                {
                    for (int columnNumber = 1; columnNumber <= columnCount; columnNumber++)
                    {
                        var cellValue = worksheet.Cells[rowNumber, columnNumber].Value;
                        if (cellValue != null)
                        {
                            rowData[columnNumber - 1] = cellValue.ToString();
                        }
                        else
                        {
                            rowData[columnNumber - 1] = "";
                        }
                    }
                    results.Add(GetModel(String.Join(",", rowData)));
                }

                return results;
            }
        }

        public static List<MyModel> GetinitialDatas()
        {
            List<MyModel> models = new List<MyModel>();
            models.Add(GetModel("1,1-10,3208.2,3210.2,2.07,52.99,0.167,0.587,0.999,60,0.226"));
            models.Add(GetModel("2,11-21,3210.2,3213.2,2.94,112.99,0.190,0.382,0.999,60,0.202"));
            models.Add(GetModel("3,22-36,3213.2,3215.9,2.74,100.64,0.175,0.409,0.999,60,0.203"));
            models.Add(GetModel("4,37-45,3215.9,3218.9,3.01,160.51,0.149,0.308,0.999,60,0.181"));
            models.Add(GetModel("5,46-68,3218.9,3225.7,6.83,546.87,0.156,0.133,0.999,60,0.145"));
            models.Add(GetModel("6,69-80,3225.7,3229.9,4.16,503.87,0.171,0.142,0.999,60,0.150"));
            models.Add(GetModel("7,81-87,3229.9,3232.3,2.43,369.64,0.162,0.177,0.999,60,0.157"));
            models.Add(GetModel("8,88-109,3232.3,3237.8,5.77,7.62,0.131,1.417,0.999,60,0.310"));
            models.Add(GetModel("9,110-120,3237.8,3241.1,3.3,0.13,0.098,3.199,0.999,60,0.619"));
            models.Add(GetModel("10,121-132,3241.1,3244,2.85,0.10,0.110,3.217,0.999,60,0.675"));
            models.Add(GetModel("11,133-156,3244,3250.9,6.95,42.31,0.120,0.661,0.999,60,0.222"));
            models.Add(GetModel("12,157-171,3250.9,3254.5,3.6,439.87,0.123,0.156,0.999,60,0.145"));
            models.Add(GetModel("13,172-181,3254.5,3256.5,1.95,361.54,0.178,0.179,0.999,60,0.161"));
            models.Add(GetModel("14,182-186,3256.5,3259,2.5,2.74,0.159,1.984,0.999,60,0.388"));
            models.Add(GetModel("15,187-211,3259,3265.4,6.46,229.74,0.101,0.244,0.999,60,0.157"));
            models.Add(GetModel("16,212-225,3265.4,3271.2,5.74,67.84,0.144,0.513,0.999,60,0.211"));
            models.Add(GetModel("17,226-237,3271.2,3273.2,2.05,46.81,0.175,0.627,0.999,60,0.234"));
            models.Add(GetModel("18,238-241,3273.2,3274.7,1.5,1.17,0.117,2.453,0.999,60,0.429"));
            models.Add(GetModel("19,242-260,3274.7,3279.8,5.09,2.35,0.139,2.070,0.999,60,0.390"));
            models.Add(GetModel("20,261-279,3279.8,3284.6,4.81,19.83,0.185,0.955,0.999,60,0.277"));
            models.Add(GetModel("21,280-330,3284.6,3300.8,16.2,907.15,0.124,0.091,0.999,60,0.127"));
            models.Add(GetModel("22,331-350,3300.8,3306.4,5.63,0.07,0.062,3.208,0.999,60,0.640"));
            models.Add(GetModel("23,351-360,3306.4,3309.8,3.37,0.11,0.079,3.215,0.999,60,0.624"));
            models.Add(GetModel("24,361-368,3309.8,3312.8,2.95,36.75,0.146,0.710,0.999,60,0.237"));
            models.Add(GetModel("25,369-375,3312.8,3314.9,2.15,0.20,0.070,3.139,0.999,60,0.541"));
            models.Add(GetModel("26,376-378,3314.9,3315.7,0.76,25.71,0.099,0.846,0.999,60,0.235"));
            models.Add(GetModel("27,379-387,3315.7,3318.6,2.98,274.32,0.161,0.217,0.999,60,0.166"));
            models.Add(GetModel("28,388-398,3318.6,3354.6,39.46,432.77,0.148,0.158,0.999,60,0.150"));
            models.Add(GetModel("29,399-420,3354.6,3361.5,6.89,125.67,0.133,0.358,0.999,60,0.185"));
            models.Add(GetModel("30,421-432,3361.5,3364.8,3.32,134.32,0.136,0.344,0.999,60,0.183"));
            return models;
        }
    }
}