using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Security;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApp2
{
    public partial class Form1 : Form
    {
        public bool Multiselect { get; set; }
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
      
        }

        private void Button1_Click(object sender, EventArgs e)
        {
            this.openFileDialog1.Filter =
"Lua |*.lua|" +
"All files (*.*)|*.*";

            this.openFileDialog1.Multiselect = true;
            this.openFileDialog1.Title = "Select Photos";

            DialogResult dr = this.openFileDialog1.ShowDialog();
            if (dr == System.Windows.Forms.DialogResult.OK)
            {
                foreach (String file in openFileDialog1.FileNames)
                {
                    try
                    {
                        ListViewItem lv2 = new ListViewItem() { Text = file };
                        listView2.Items.Add(lv2);
                        Console.WriteLine(file);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Error: " + ex.Message);
                    }
                }
            }
        }
        public bool ThumbnailCallback()
        {
            return false;
        }

        private void ListView2_DoubleClick(object sender, EventArgs e)
        {
            for (int i = 0; i < listView2.Items.Count; i++)
            {
                listView2.Items[i].Checked = true;
            }
        }
        private string GetName(string input)
        {
            string pattern = @"(.*lua\\)(.*).lua";
            string substitution = @"$2";
            RegexOptions options = RegexOptions.Multiline;
            Regex regex = new Regex(pattern, options);
            string result = regex.Replace(input, substitution);
            return result;
        }
        private void Button2_Click(object sender, EventArgs e)
        {
            ListView.CheckedListViewItemCollection checkedItems = listView2.CheckedItems;
            foreach (ListViewItem item in checkedItems)
            {
              
                string[] arrayid = new string[] { GetName(item.Text).ToString()};
                for (int i = 0; i < arrayid.Length; i++)
                {
                    Console.WriteLine(arrayid[i]);
                    string cmdl = @"/C java -jar unluac_2015_06_13.jar "+ arrayid[i]+" > "+ GetName(arrayid[i])+".lua";
                    Process.Start("CMD.exe", cmdl);
                }
            }
         
        }

        private void Button3_Click(object sender, EventArgs e)
        {
            listView2.Items.Clear();
        }
    }
}