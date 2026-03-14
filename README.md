# JeedomIPPPrinterInkStatus
Bash script that provide json information about ink level for an IPP printer

<H3> general inforamtion</H3>
<p>based on ipptool</p> 
<p>require cups-ipp-utils
<code>sudo apt-get install cups-ipp-utils</code></p>

<h3>installation</h3>
<code>cd /var/www/html/pulgins/script/data/
## git pull https://github.com/Remi39cl199/JeedomIPPPrinterInkStatus/blob/main/jeedom_ipp_printer_ink_status.sh
sudo chmod +x ./jeedom_ipp_printer_ink_status.sh
sudo chown www-data:www-data ./jeedom_ipp_printer_ink_status.sh</code>
<h3>Usage</h3>
<code>/var/www/html/plugins/script/data/jeedom_ipp_printer_ink_status.sh IP_ADDRESS_OF_IPP_PRINTER</code>

<h3>Output</h3>
<code>{
 "printer":"IPP_PRINTER_NAME",
 "ip":"IPP_PRINTER_IP_ADDRESS",
 "state":"idle",
 "state_reasons":"marker-supply-low-warning",
 "ink":{
  "color":{
   "level":0,
   "percent":0,
   "low_threshold":15,
   "status":"empty"
  },
  "black":{
   "level":0,
   "percent":0,
   "low_threshold":15,
   "status":"empty"
  }
 }
}</code>
