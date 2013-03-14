<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns="http://www.crossref.org/qschema/2.0"
  exclude-result-prefixes="crq xs"
  version="2.0">
  
  <xsl:template name="main">
    <body>
      <xsl:apply-templates select="/*" mode="look-for-bib"/>  
    </body>
  </xsl:template>
  
  <xsl:template match="node()" mode="look-for-bib">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- Query all citations that have an ID and that do not already have a DOI.
       There should be some Schematron running beforehand so that citations 
       without ID will be reported. -->
  <xsl:template match="ref[@id][not(pub-id[@pub-id-type eq 'doi'])]" mode="look-for-bib">
    <query key="{@id}" enable-multiple-hits="true">
      <xsl:apply-templates mode="transform-bib"/>  
    </query>
  </xsl:template>
  
  <xsl:template match="mixed-citation" mode="transform-bib">
    <unstructured_citation>
      <xsl:apply-templates mode="#current"/>
    </unstructured_citation>
  </xsl:template>
  
  <xsl:template match="text()" mode="transform-bib">
    <xsl:value-of select="replace(., '&#xad;', '')"/>
  </xsl:template>
  
  <!-- Apparently i and b will be discarded during resolution. So we’ll just
    dissolve them. -->
  <xsl:template match="italic" mode="transform-bib_DISABLED">
    <i>
      <xsl:apply-templates mode="#current"/>
    </i>
  </xsl:template>
  
  <xsl:template match="bold" mode="transform-bib_DISABLED">
    <b>
      <xsl:apply-templates mode="#current"/>
    </b>
  </xsl:template>
</xsl:stylesheet>