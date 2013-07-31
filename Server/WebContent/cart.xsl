<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html"/>
<xsl:template match="/">
 <html>
  <head>
   <title><xsl:value-of select="rss/channel/title"/></title>
  </head>
  <body>
   <h1><a href="{rss/channel/link}">
   <xsl:value-of select="rss/channel/title"/></a></h1>
   
   <xsl:for-each select="rss/channel/item">
    <h2><a href="{link}">
    <xsl:value-of select="title"/></a></h2>
    <div name="descriptionDiv">
     <xsl:value-of select="description" 
         disable-output-escaping="yes"/>
    </div>
   </xsl:for-each>   
  </body>
 </html>
</xsl:template>

</xsl:stylesheet>